import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/farm_model.dart';
import '../models/sensor_data_model.dart';
import '../services/local_data_service.dart';
import '../utils/constants.dart';

class FarmProvider with ChangeNotifier {
  final LocalDataService _dataService = LocalDataService();
  List<Farm> _farms = [];
  Farm? _selectedFarm;
  Field? _selectedField;
  SensorData? _latestSensorData;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  Field? get selectedField => _selectedField;
  SensorData? get latestSensorData => _latestSensorData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FarmProvider() {
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Constants.sensorDataRefreshInterval,
      (_) => refreshSensorData(),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> loadFarms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _farms = await _dataService.getFarms();
      if (_farms.isNotEmpty && _selectedFarm == null) {
        _selectedFarm = _farms.first;
        if (_selectedFarm!.fields.isNotEmpty) {
          _selectedField = _selectedFarm!.fields.first;
          await refreshSensorData();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectFarm(Farm farm) async {
    _selectedFarm = farm;
    if (farm.fields.isNotEmpty) {
      _selectedField = farm.fields.first;
      await refreshSensorData();
    } else {
      _selectedField = null;
      _latestSensorData = null;
    }
    notifyListeners();
  }

  Future<void> selectField(Field field) async {
    _selectedField = field;
    await refreshSensorData();
    notifyListeners();
  }

  Future<void> refreshSensorData() async {
    if (_selectedField == null) return;

    try {
      _latestSensorData =
          await _dataService.getLatestSensorData(_selectedField!.id);
      notifyListeners();
    } catch (e) {
      // Silently fail for auto-refresh, but log error
      debugPrint('Error refreshing sensor data: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

