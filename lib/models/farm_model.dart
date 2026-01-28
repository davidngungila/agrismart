import 'sensor_data_model.dart';
import 'irrigation_model.dart';

class Farm {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime createdAt;
  final List<Field> fields;

  Farm({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    this.latitude,
    this.longitude,
    this.address,
    required this.createdAt,
    this.fields = const [],
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => Field.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}

class Field {
  final String id;
  final String farmId;
  final String name;
  final String? cropType;
  final double area; // in hectares
  final DateTime createdAt;
  final SensorData? latestSensorData;
  final IrrigationSettings irrigationSettings;

  Field({
    required this.id,
    required this.farmId,
    required this.name,
    this.cropType,
    required this.area,
    required this.createdAt,
    this.latestSensorData,
    required this.irrigationSettings,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      name: json['name'] as String,
      cropType: json['cropType'] as String?,
      area: (json['area'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      latestSensorData: json['latestSensorData'] != null
          ? SensorData.fromJson(json['latestSensorData'] as Map<String, dynamic>)
          : null,
      irrigationSettings: IrrigationSettings.fromJson(
          json['irrigationSettings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'cropType': cropType,
      'area': area,
      'createdAt': createdAt.toIso8601String(),
      'latestSensorData': latestSensorData?.toJson(),
      'irrigationSettings': irrigationSettings.toJson(),
    };
  }
}

