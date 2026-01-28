import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/sensor_data_model.dart';
import '../widgets/custom_app_bar.dart';
import 'device_settings_screen.dart';
import 'firmware_update_screen.dart';
import 'restart_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Devices',
        showNotifications: false,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          final sensorData = farmProvider.latestSensorData;
          final field = farmProvider.selectedField;

          if (field == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No field selected',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Overview Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1B5E20),
                        const Color(0xFF2E7D32),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sensors,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device Status',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sensorData?.deviceStatus.isOnline == true
                                      ? 'ONLINE'
                                      : 'OFFLINE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sensorData?.deviceStatus.isOnline == true
                                  ? Colors.green[400]
                                  : Colors.red[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              sensorData?.deviceStatus.isOnline == true
                                  ? 'ACTIVE'
                                  : 'INACTIVE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Device Details
                if (sensorData != null) ...[
                  _buildDeviceInfoCard(
                    context,
                    'Connection Status',
                    sensorData.deviceStatus.isOnline ? 'Connected' : 'Disconnected',
                    sensorData.deviceStatus.isOnline
                        ? Icons.wifi
                        : Icons.wifi_off,
                    sensorData.deviceStatus.isOnline
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildDeviceInfoCard(
                    context,
                    'Sensor Status',
                    sensorData.deviceStatus.sensorConnected
                        ? 'All Sensors Connected'
                        : 'Sensors Disconnected',
                    sensorData.deviceStatus.sensorConnected
                        ? Icons.check_circle
                        : Icons.error,
                    sensorData.deviceStatus.sensorConnected
                        ? Colors.green
                        : Colors.orange,
                  ),
                  if (sensorData.deviceStatus.batteryLevel != null) ...[
                    const SizedBox(height: 12),
                    _buildBatteryCard(context, sensorData.deviceStatus),
                  ],
                  if (sensorData.deviceStatus.lastSeen != null) ...[
                    const SizedBox(height: 12),
                    _buildDeviceInfoCard(
                      context,
                      'Last Seen',
                      _formatLastSeen(sensorData.deviceStatus.lastSeen!),
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                // Device Management Section
                Text(
                  'Device Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  icon: Icons.refresh,
                  title: 'Refresh Device',
                  subtitle: 'Update device status',
                  color: Colors.blue,
                  onTap: () {
                    farmProvider.refreshSensorData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Device status refreshed')),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.settings,
                  title: 'Device Settings',
                  subtitle: 'Configure device parameters',
                  color: Colors.grey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeviceSettingsScreen(
                          deviceId: 'DEV-${field.id}',
                          deviceName: '${field.name} Sensor Device',
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.update,
                  title: 'Firmware Update',
                  subtitle: 'Check for updates',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FirmwareUpdateScreen(
                          deviceId: 'DEV-${field.id}',
                          deviceName: '${field.name} Sensor Device',
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.restart_alt,
                  title: 'Restart Device',
                  subtitle: 'Reboot the device',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestartDeviceScreen(
                          deviceId: 'DEV-${field.id}',
                          deviceName: '${field.name} Sensor Device',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Connected Sensors
                Text(
                  'Connected Sensors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSensorItem(
                  context,
                  'Soil Moisture Sensor',
                  Icons.water_drop,
                  Colors.blue,
                  sensorData?.deviceStatus.sensorConnected ?? false,
                ),
                _buildSensorItem(
                  context,
                  'Temperature Sensor',
                  Icons.thermostat,
                  Colors.orange,
                  sensorData?.deviceStatus.sensorConnected ?? false,
                ),
                _buildSensorItem(
                  context,
                  'Humidity Sensor',
                  Icons.opacity,
                  Colors.green,
                  sensorData?.deviceStatus.sensorConnected ?? false,
                ),
                _buildSensorItem(
                  context,
                  'Light Sensor',
                  Icons.light_mode,
                  Colors.amber,
                  sensorData?.deviceStatus.sensorConnected ?? false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryCard(BuildContext context, DeviceStatus deviceStatus) {
    final batteryLevel = deviceStatus.batteryLevel ?? 0;
    Color batteryColor;
    if (batteryLevel > 50) {
      batteryColor = Colors.green;
    } else if (batteryLevel > 20) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: batteryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.battery_charging_full,
                      color: batteryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery Level',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$batteryLevel%',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: batteryLevel / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: Colors.grey[400], size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSensorItem(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    bool isConnected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? color.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

