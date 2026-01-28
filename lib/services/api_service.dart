import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';
import '../models/sensor_data_model.dart';
import '../models/irrigation_model.dart';
import '../models/threshold_model.dart';
import '../models/alert_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  String get baseUrl => Constants.apiBaseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String?;
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String name, String? phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String?;
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Farms
  Future<List<Farm>> getFarms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farms'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['farms'] as List)
            .map((e) => Farm.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch farms: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching farms: $e');
    }
  }

  Future<Farm> getFarm(String farmId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farms/$farmId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Farm.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch farm: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching farm: $e');
    }
  }

  // Sensor Data
  Future<SensorData> getLatestSensorData(String fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fields/$fieldId/sensor-data/latest'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return SensorData.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch sensor data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching sensor data: $e');
    }
  }

  Future<List<SensorData>> getHistoricalSensorData(
    String fieldId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/fields/$fieldId/sensor-data?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((e) => SensorData.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch historical data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching historical data: $e');
    }
  }

  // Irrigation
  Future<void> controlIrrigation(
      String fieldId, bool activate, IrrigationMode mode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fields/$fieldId/irrigation/control'),
        headers: _headers,
        body: jsonEncode({
          'activate': activate,
          'mode': mode.toString(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to control irrigation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error controlling irrigation: $e');
    }
  }

  Future<void> updateIrrigationSettings(
      String fieldId, IrrigationSettings settings) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/fields/$fieldId/irrigation/settings'),
        headers: _headers,
        body: jsonEncode(settings.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update irrigation settings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating irrigation settings: $e');
    }
  }

  Future<List<IrrigationHistory>> getIrrigationHistory(
    String fieldId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      String url = '$baseUrl/fields/$fieldId/irrigation/history';
      if (startDate != null && endDate != null) {
        url +=
            '?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['history'] as List)
            .map((e) =>
                IrrigationHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch irrigation history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching irrigation history: $e');
    }
  }

  // Thresholds
  Future<ThresholdSettings> getThresholdSettings(String fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fields/$fieldId/thresholds'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ThresholdSettings.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch thresholds: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching thresholds: $e');
    }
  }

  Future<void> updateThresholdSettings(
      String fieldId, ThresholdSettings settings) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/fields/$fieldId/thresholds'),
        headers: _headers,
        body: jsonEncode(settings.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update thresholds: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating thresholds: $e');
    }
  }

  // Alerts
  Future<List<Alert>> getAlerts(String? fieldId, {bool? unreadOnly}) async {
    try {
      String url = '$baseUrl/alerts';
      if (fieldId != null) url += '?fieldId=$fieldId';
      if (unreadOnly == true) {
        url += fieldId != null ? '&unreadOnly=true' : '?unreadOnly=true';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['alerts'] as List)
            .map((e) => Alert.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch alerts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  Future<void> markAlertAsRead(String alertId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$alertId/read'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to mark alert as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking alert as read: $e');
    }
  }
}

