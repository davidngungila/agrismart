class Alert {
  final String id;
  final String fieldId;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Alert({
    required this.id,
    required this.fieldId,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AlertType.fromString(json['type'] as String),
      severity: AlertSeverity.fromString(json['severity'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'title': title,
      'message': message,
      'type': type.toString(),
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}

enum AlertType {
  soilMoisture,
  temperature,
  humidity,
  lightIntensity,
  deviceOffline,
  irrigation,
  system;

  static AlertType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'soil_moisture':
      case 'soilmoisture':
        return AlertType.soilMoisture;
      case 'temperature':
        return AlertType.temperature;
      case 'humidity':
        return AlertType.humidity;
      case 'light_intensity':
      case 'lightintensity':
        return AlertType.lightIntensity;
      case 'device_offline':
      case 'deviceoffline':
        return AlertType.deviceOffline;
      case 'irrigation':
        return AlertType.irrigation;
      case 'system':
        return AlertType.system;
      default:
        return AlertType.system;
    }
  }

  @override
  String toString() {
    switch (this) {
      case AlertType.soilMoisture:
        return 'soil_moisture';
      case AlertType.temperature:
        return 'temperature';
      case AlertType.humidity:
        return 'humidity';
      case AlertType.lightIntensity:
        return 'light_intensity';
      case AlertType.deviceOffline:
        return 'device_offline';
      case AlertType.irrigation:
        return 'irrigation';
      case AlertType.system:
        return 'system';
    }
  }
}

enum AlertSeverity {
  info,
  warning,
  critical;

  static AlertSeverity fromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      case 'info':
      default:
        return AlertSeverity.info;
    }
  }

  @override
  String toString() {
    switch (this) {
      case AlertSeverity.info:
        return 'info';
      case AlertSeverity.warning:
        return 'warning';
      case AlertSeverity.critical:
        return 'critical';
    }
  }
}


