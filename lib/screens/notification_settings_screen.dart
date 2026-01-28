import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _soilMoistureAlerts = true;
  bool _temperatureAlerts = true;
  bool _humidityAlerts = true;
  bool _lightIntensityAlerts = true;
  bool _deviceOfflineAlerts = true;
  bool _irrigationAlerts = true;
  String _alertFrequency = 'immediate'; // immediate, hourly, daily

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Channels
            Text(
              'Notification Channels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive notifications in the app'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive alerts via email'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive alerts via SMS'),
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Alert Types
            Text(
              'Alert Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildAlertTypeTile(
                    'Soil Moisture Alerts',
                    Icons.water_drop,
                    Colors.blue,
                    _soilMoistureAlerts,
                    (value) => setState(() => _soilMoistureAlerts = value),
                  ),
                  const Divider(height: 1),
                  _buildAlertTypeTile(
                    'Temperature Alerts',
                    Icons.thermostat,
                    Colors.orange,
                    _temperatureAlerts,
                    (value) => setState(() => _temperatureAlerts = value),
                  ),
                  const Divider(height: 1),
                  _buildAlertTypeTile(
                    'Humidity Alerts',
                    Icons.opacity,
                    Colors.green,
                    _humidityAlerts,
                    (value) => setState(() => _humidityAlerts = value),
                  ),
                  const Divider(height: 1),
                  _buildAlertTypeTile(
                    'Light Intensity Alerts',
                    Icons.light_mode,
                    Colors.amber,
                    _lightIntensityAlerts,
                    (value) => setState(() => _lightIntensityAlerts = value),
                  ),
                  const Divider(height: 1),
                  _buildAlertTypeTile(
                    'Device Offline Alerts',
                    Icons.wifi_off,
                    Colors.red,
                    _deviceOfflineAlerts,
                    (value) => setState(() => _deviceOfflineAlerts = value),
                  ),
                  const Divider(height: 1),
                  _buildAlertTypeTile(
                    'Irrigation Alerts',
                    Icons.water_drop,
                    Colors.cyan,
                    _irrigationAlerts,
                    (value) => setState(() => _irrigationAlerts = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Alert Frequency
            Text(
              'Alert Frequency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Immediate'),
                    subtitle: const Text('Receive alerts as soon as they occur'),
                    value: 'immediate',
                    groupValue: _alertFrequency,
                    onChanged: (value) {
                      setState(() {
                        _alertFrequency = value!;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Hourly Summary'),
                    subtitle: const Text('Receive a summary every hour'),
                    value: 'hourly',
                    groupValue: _alertFrequency,
                    onChanged: (value) {
                      setState(() {
                        _alertFrequency = value!;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Daily Summary'),
                    subtitle: const Text('Receive a summary once per day'),
                    value: 'daily',
                    groupValue: _alertFrequency,
                    onChanged: (value) {
                      setState(() {
                        _alertFrequency = value!;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTypeTile(
    String title,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1B5E20),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved')),
    );
  }
}

