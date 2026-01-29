class IrrigationSettings {
  final IrrigationMode mode;
  final double? soilMoistureThreshold; // percentage for auto mode
  final int? durationMinutes; // irrigation duration
  final bool isActive;

  IrrigationSettings({
    required this.mode,
    this.soilMoistureThreshold,
    this.durationMinutes,
    this.isActive = false,
  });

  factory IrrigationSettings.fromJson(Map<String, dynamic> json) {
    return IrrigationSettings(
      mode: IrrigationMode.fromString(json['mode'] as String),
      soilMoistureThreshold:
          json['soilMoistureThreshold'] != null
              ? (json['soilMoistureThreshold'] as num).toDouble()
              : null,
      durationMinutes: json['durationMinutes'] as int?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toString(),
      'soilMoistureThreshold': soilMoistureThreshold,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
    };
  }
}

enum IrrigationMode {
  manual,
  automatic;

  static IrrigationMode fromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'automatic':
      case 'auto':
        return IrrigationMode.automatic;
      case 'manual':
      default:
        return IrrigationMode.manual;
    }
  }

  @override
  String toString() {
    switch (this) {
      case IrrigationMode.manual:
        return 'manual';
      case IrrigationMode.automatic:
        return 'automatic';
    }
  }
}

class IrrigationHistory {
  final String id;
  final String fieldId;
  final DateTime startTime;
  final DateTime? endTime;
  final IrrigationMode mode;
  final String? triggeredBy; // 'user' or 'automatic'
  final double? soilMoistureBefore;
  final double? soilMoistureAfter;

  IrrigationHistory({
    required this.id,
    required this.fieldId,
    required this.startTime,
    this.endTime,
    required this.mode,
    this.triggeredBy,
    this.soilMoistureBefore,
    this.soilMoistureAfter,
  });

  factory IrrigationHistory.fromJson(Map<String, dynamic> json) {
    return IrrigationHistory(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      mode: IrrigationMode.fromString(json['mode'] as String),
      triggeredBy: json['triggeredBy'] as String?,
      soilMoistureBefore: json['soilMoistureBefore'] != null
          ? (json['soilMoistureBefore'] as num).toDouble()
          : null,
      soilMoistureAfter: json['soilMoistureAfter'] != null
          ? (json['soilMoistureAfter'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'mode': mode.toString(),
      'triggeredBy': triggeredBy,
      'soilMoistureBefore': soilMoistureBefore,
      'soilMoistureAfter': soilMoistureAfter,
    };
  }
}


