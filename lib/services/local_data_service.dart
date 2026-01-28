import 'dart:math';

import '../models/farm_model.dart';
import '../models/sensor_data_model.dart';
import '../models/irrigation_model.dart';
import '../models/threshold_model.dart';
import '../models/alert_model.dart';

/// Local in-memory data service used instead of remote HTTP APIs.
/// This lets the app run fully offline with demo data.
class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal() {
    _initDemoData();
  }

  final List<Farm> _farms = [];
  final Map<String, ThresholdSettings> _thresholds = {};
  final Map<String, IrrigationSettings> _irrigationSettings = {};
  final Map<String, List<IrrigationHistory>> _irrigationHistory = {};

  void _initDemoData() {
    if (_farms.isNotEmpty) return;

    final now = DateTime.now();

    final field1 = Field(
      id: 'field-1',
      farmId: 'farm-1',
      name: 'North Field',
      cropType: 'Wheat',
      area: 2.5,
      createdAt: now.subtract(const Duration(days: 120)),
      irrigationSettings: IrrigationSettings(
        mode: IrrigationMode.automatic,
        soilMoistureThreshold: 40,
        durationMinutes: 30,
        isActive: false,
      ),
    );

    final field2 = Field(
      id: 'field-2',
      farmId: 'farm-1',
      name: 'South Field',
      cropType: 'Maize',
      area: 3.2,
      createdAt: now.subtract(const Duration(days: 90)),
      irrigationSettings: IrrigationSettings(
        mode: IrrigationMode.manual,
        soilMoistureThreshold: 35,
        durationMinutes: 25,
        isActive: false,
      ),
    );

    _farms.add(
      Farm(
        id: 'farm-1',
        name: 'Demo Smart Farm',
        description: 'Sample farm for offline demo',
        userId: 'local-user',
        latitude: -1.2833,
        longitude: 36.8167,
        address: 'Local demo address',
        createdAt: now.subtract(const Duration(days: 180)),
        fields: [field1, field2],
      ),
    );

    // Default thresholds per field
    for (final field in [field1, field2]) {
      _thresholds[field.id] = ThresholdSettings();
      _irrigationSettings[field.id] = field.irrigationSettings;
      _irrigationHistory[field.id] = [];
    }
  }

  Future<List<Farm>> getFarms() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _farms;
  }

  Future<SensorData> getLatestSensorData(String fieldId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final random = Random(fieldId.hashCode + DateTime.now().minute);

    final thresholds = _thresholds[fieldId] ?? ThresholdSettings();

    double rnd(double min, double max) =>
        min + (max - min) * random.nextDouble();

    final data = SensorData(
      id: 'sensor-$fieldId-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      soilMoisture: rnd(
        thresholds.minSoilMoisture * 0.8,
        thresholds.maxSoilMoisture * 0.9,
      ),
      temperature: rnd(
        thresholds.minTemperature,
        thresholds.maxTemperature,
      ),
      humidity: rnd(
        thresholds.minHumidity,
        thresholds.maxHumidity,
      ),
      lightIntensity: rnd(
        thresholds.minLightIntensity,
        thresholds.maxLightIntensity,
      ),
      timestamp: DateTime.now(),
      deviceStatus: DeviceStatus(
        isOnline: true,
        batteryLevel: 80 + random.nextInt(20),
        lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
        sensorConnected: true,
      ),
    );

    return data;
  }

  Future<List<SensorData>> getHistoricalSensorData(
    String fieldId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final random = Random(fieldId.hashCode);
    final thresholds = _thresholds[fieldId] ?? ThresholdSettings();

    final days = endDate.difference(startDate).inDays.clamp(1, 90);
    final List<SensorData> data = [];
    for (int i = 0; i <= days; i++) {
      final ts = startDate.add(Duration(days: i));
      double rnd(double min, double max) =>
          min + (max - min) * (0.7 + 0.6 * random.nextDouble()) / 2;
      data.add(
        SensorData(
          id: 'hist-$fieldId-$i',
          fieldId: fieldId,
          soilMoisture:
              rnd(thresholds.minSoilMoisture, thresholds.maxSoilMoisture),
          temperature:
              rnd(thresholds.minTemperature, thresholds.maxTemperature),
          humidity: rnd(thresholds.minHumidity, thresholds.maxHumidity),
          lightIntensity: rnd(
              thresholds.minLightIntensity, thresholds.maxLightIntensity),
          timestamp: ts,
          deviceStatus: DeviceStatus(
            isOnline: true,
            batteryLevel: 70 + random.nextInt(30),
            lastSeen: ts,
            sensorConnected: true,
          ),
        ),
      );
    }
    return data;
  }

  Future<IrrigationSettings> getIrrigationSettings(String fieldId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _irrigationSettings[fieldId] ??
        IrrigationSettings(mode: IrrigationMode.manual);
  }

  Future<void> updateIrrigationSettings(
    String fieldId,
    IrrigationSettings settings,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _irrigationSettings[fieldId] = settings;
  }

  Future<void> controlIrrigation(
    String fieldId,
    bool activate,
    IrrigationMode mode,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final current = _irrigationSettings[fieldId] ??
        IrrigationSettings(mode: mode, isActive: activate);
    _irrigationSettings[fieldId] = IrrigationSettings(
      mode: mode,
      soilMoistureThreshold: current.soilMoistureThreshold,
      durationMinutes: current.durationMinutes,
      isActive: activate,
    );
  }

  Future<List<IrrigationHistory>> getIrrigationHistory(
    String fieldId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _irrigationHistory[fieldId] ?? [];
  }

  Future<ThresholdSettings> getThresholdSettings(String fieldId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _thresholds[fieldId] ?? ThresholdSettings();
  }

  Future<void> updateThresholdSettings(
    String fieldId,
    ThresholdSettings settings,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _thresholds[fieldId] = settings;
  }

  // Alerts: purely local list
  final List<Alert> _alerts = [];

  Future<List<Alert>> getAlerts(String? fieldId, {bool? unreadOnly}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    Iterable<Alert> result = _alerts;
    if (fieldId != null) {
      result = result.where((a) => a.fieldId == fieldId);
    }
    if (unreadOnly == true) {
      result = result.where((a) => !a.isRead);
    }
    final list = result.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> addAlert(Alert alert) async {
    _alerts.insert(0, alert);
  }

  Future<void> markAlertAsRead(String alertId) async {
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      final alert = _alerts[idx];
      _alerts[idx] = Alert(
        id: alert.id,
        fieldId: alert.fieldId,
        title: alert.title,
        message: alert.message,
        type: alert.type,
        severity: alert.severity,
        timestamp: alert.timestamp,
        isRead: true,
        metadata: alert.metadata,
      );
    }
  }
}


