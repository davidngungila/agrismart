import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/alert_model.dart';
import '../services/local_data_service.dart';
import '../services/notification_service.dart';

class AlertProvider with ChangeNotifier {
  final LocalDataService _dataService = LocalDataService();
  final NotificationService _notificationService = NotificationService();
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  List<Alert> get alerts => _alerts;
  List<Alert> get unreadAlerts =>
      _alerts.where((a) => !a.isRead).toList();
  int get unreadCount => unreadAlerts.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AlertProvider() {
    _notificationService.initialize();
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadAlerts(),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> loadAlerts({String? fieldId, bool unreadOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alerts =
          await _dataService.getAlerts(fieldId, unreadOnly: unreadOnly);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String alertId) async {
    try {
      await _dataService.markAlertAsRead(alertId);
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        _alerts[index] = Alert(
          id: _alerts[index].id,
          fieldId: _alerts[index].fieldId,
          title: _alerts[index].title,
          message: _alerts[index].message,
          type: _alerts[index].type,
          severity: _alerts[index].severity,
          timestamp: _alerts[index].timestamp,
          isRead: true,
          metadata: _alerts[index].metadata,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> showAlert(Alert alert) async {
    // Add to local list
    _alerts.insert(0, alert);
    await _dataService.addAlert(alert);
    notifyListeners();

    // Show notification
    await _notificationService.showLocalNotification(alert);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

