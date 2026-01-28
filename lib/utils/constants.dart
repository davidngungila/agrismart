class Constants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.agrismart.com/v1';
  // For development, you can use: 'http://localhost:3000/api/v1'
  // Or a mock server: 'https://mock-api.agrismart.com/v1'

  // App Configuration
  static const String appName = 'AgriSmart';
  static const String appVersion = '1.0.0';

  // Refresh Intervals
  static const Duration sensorDataRefreshInterval = Duration(minutes: 2);
  static const Duration dashboardRefreshInterval = Duration(minutes: 5);

  // Default Thresholds
  static const double defaultMinSoilMoisture = 30.0;
  static const double defaultMaxSoilMoisture = 80.0;
  static const double defaultMinTemperature = 10.0;
  static const double defaultMaxTemperature = 35.0;
  static const double defaultMinHumidity = 40.0;
  static const double defaultMaxHumidity = 90.0;
  static const double defaultMinLightIntensity = 1000.0;
  static const double defaultMaxLightIntensity = 100000.0;

  // Irrigation Settings
  static const int defaultIrrigationDurationMinutes = 30;
  static const double defaultAutoIrrigationThreshold = 40.0;

  // Colors for Status Indicators
  static const int colorNormal = 0xFF4CAF50; // Green
  static const int colorWarning = 0xFFFF9800; // Orange
  static const int colorCritical = 0xFFF44336; // Red
  static const int colorOffline = 0xFF9E9E9E; // Grey

  // Chart Colors
  static const int chartPrimaryColor = 0xFF2196F3; // Blue
  static const int chartSecondaryColor = 0xFF4CAF50; // Green
  static const int chartTertiaryColor = 0xFFFF9800; // Orange
}

