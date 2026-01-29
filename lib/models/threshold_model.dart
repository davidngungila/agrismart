class ThresholdSettings {
  final double minSoilMoisture;
  final double maxSoilMoisture;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final double minLightIntensity;
  final double maxLightIntensity;

  ThresholdSettings({
    this.minSoilMoisture = 30.0,
    this.maxSoilMoisture = 80.0,
    this.minTemperature = 10.0,
    this.maxTemperature = 35.0,
    this.minHumidity = 40.0,
    this.maxHumidity = 90.0,
    this.minLightIntensity = 1000.0,
    this.maxLightIntensity = 100000.0,
  });

  factory ThresholdSettings.fromJson(Map<String, dynamic> json) {
    return ThresholdSettings(
      minSoilMoisture: (json['minSoilMoisture'] as num?)?.toDouble() ?? 30.0,
      maxSoilMoisture: (json['maxSoilMoisture'] as num?)?.toDouble() ?? 80.0,
      minTemperature: (json['minTemperature'] as num?)?.toDouble() ?? 10.0,
      maxTemperature: (json['maxTemperature'] as num?)?.toDouble() ?? 35.0,
      minHumidity: (json['minHumidity'] as num?)?.toDouble() ?? 40.0,
      maxHumidity: (json['maxHumidity'] as num?)?.toDouble() ?? 90.0,
      minLightIntensity:
          (json['minLightIntensity'] as num?)?.toDouble() ?? 1000.0,
      maxLightIntensity:
          (json['maxLightIntensity'] as num?)?.toDouble() ?? 100000.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minSoilMoisture': minSoilMoisture,
      'maxSoilMoisture': maxSoilMoisture,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'minLightIntensity': minLightIntensity,
      'maxLightIntensity': maxLightIntensity,
    };
  }
}


