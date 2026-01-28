import 'threshold_model.dart';

class SensorData {
  final String id;
  final String fieldId;
  final double soilMoisture; // percentage (0-100)
  final double temperature; // Celsius
  final double humidity; // percentage (0-100)
  final double lightIntensity; // lux
  final DateTime timestamp;
  final DeviceStatus deviceStatus;

  SensorData({
    required this.id,
    required this.fieldId,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.timestamp,
    required this.deviceStatus,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      soilMoisture: (json['soilMoisture'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      lightIntensity: (json['lightIntensity'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceStatus: DeviceStatus.fromJson(
          json['deviceStatus'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'soilMoisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'lightIntensity': lightIntensity,
      'timestamp': timestamp.toIso8601String(),
      'deviceStatus': deviceStatus.toJson(),
    };
  }

  SensorStatus getStatus(ThresholdSettings thresholds) {
    if (soilMoisture < thresholds.minSoilMoisture ||
        soilMoisture > thresholds.maxSoilMoisture ||
        temperature > thresholds.maxTemperature ||
        temperature < thresholds.minTemperature ||
        humidity < thresholds.minHumidity ||
        lightIntensity < thresholds.minLightIntensity) {
      return SensorStatus.critical;
    } else if (soilMoisture < thresholds.minSoilMoisture * 1.1 ||
        temperature > thresholds.maxTemperature * 0.9 ||
        humidity < thresholds.minHumidity * 1.1 ||
        lightIntensity < thresholds.minLightIntensity * 1.1) {
      return SensorStatus.warning;
    }
    return SensorStatus.normal;
  }
}

enum SensorStatus {
  normal,
  warning,
  critical;

  String get label {
    switch (this) {
      case SensorStatus.normal:
        return 'Normal';
      case SensorStatus.warning:
        return 'Warning';
      case SensorStatus.critical:
        return 'Critical';
    }
  }
}

class DeviceStatus {
  final bool isOnline;
  final int? batteryLevel; // percentage (0-100)
  final DateTime? lastSeen;
  final bool sensorConnected;

  DeviceStatus({
    required this.isOnline,
    this.batteryLevel,
    this.lastSeen,
    required this.sensorConnected,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      isOnline: json['isOnline'] as bool,
      batteryLevel: json['batteryLevel'] as int?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      sensorConnected: json['sensorConnected'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'batteryLevel': batteryLevel,
      'lastSeen': lastSeen?.toIso8601String(),
      'sensorConnected': sensorConnected,
    };
  }
}

