import 'package:flutter/foundation.dart';
import '../models/irrigation_model.dart';
import '../services/local_data_service.dart';

class IrrigationProvider with ChangeNotifier {
  final LocalDataService _dataService = LocalDataService();
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _irrigationStatus = {}; // fieldId -> isActive

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isIrrigationActive(String fieldId) {
    return _irrigationStatus[fieldId] ?? false;
  }

  Future<void> controlIrrigation(
      String fieldId, bool activate, IrrigationMode mode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dataService.controlIrrigation(fieldId, activate, mode);
      _irrigationStatus[fieldId] = activate;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIrrigationSettings(
      String fieldId, IrrigationSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dataService.updateIrrigationSettings(fieldId, settings);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<IrrigationHistory>> getIrrigationHistory(
    String fieldId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dataService.getIrrigationHistory(
          fieldId, startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}

