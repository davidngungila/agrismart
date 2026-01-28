import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
import '../models/sensor_data_model.dart';
import '../models/threshold_model.dart';
import '../models/farm_model.dart';
import '../models/alert_model.dart';
import '../widgets/sensor_card.dart';
import '../widgets/device_status_card.dart';
import '../widgets/custom_app_bar.dart';
import 'analytics_screen.dart';
import 'irrigation_control_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';
import 'devices_screen.dart';
import 'history_screen.dart';
import 'reports_screen.dart';
import 'help_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      farmProvider.loadFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard();
      case 1:
        return const IrrigationControlScreen();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    return Consumer3<FarmProvider, AlertProvider, AuthProvider>(
      builder: (context, farmProvider, alertProvider, authProvider, _) {
        final sensorData = farmProvider.latestSensorData;
        final thresholds = ThresholdSettings();

        return Column(
          children: [
            // Custom App Bar for Dashboard
            CustomAppBar(
              title: 'Dashboard',
              showBackButton: false,
              showNotifications: true,
            ),
                // Main Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions
                          if (farmProvider.selectedField != null) ...[
                            _buildQuickActions(context, farmProvider),
                            const SizedBox(height: 20),
                          ],
                          // Farm/Field Selector
                          if (farmProvider.farms.isNotEmpty) ...[
                            _buildFarmSelector(farmProvider),
                            const SizedBox(height: 20),
                          ],
                          // Services Section
                          _buildServicesSection(context, farmProvider),
                          const SizedBox(height: 20),
                          // Sensor Data Section
                          if (sensorData != null) ...[
                            _buildSensorDataSection(
                                context, sensorData, thresholds),
                            const SizedBox(height: 20),
                          ],
                          // Device Status
                          if (sensorData != null)
                            DeviceStatusCard(deviceStatus: sensorData.deviceStatus),
                          const SizedBox(height: 20),
                          // Recent Activity / Alerts Preview
                      _buildRecentActivity(context, alertProvider),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, user, AlertProvider alertProvider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.toUpperCase() ?? 'FARMER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (user?.phone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.phone!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlertsScreen(),
                        ),
                      );
                    },
                  ),
                  if (alertProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          alertProvider.unreadCount > 9
                              ? '9+'
                              : '${alertProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Balance/Status Card
          _buildStatusCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _) {
        final sensorData = farmProvider.latestSensorData;
        final field = farmProvider.selectedField;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIELD STATUS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field?.name ?? 'No Field Selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sensorData != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last Update: ${_formatTimestamp(sensorData.timestamp)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 20),
                onPressed: () {
                  // Navigate to field details
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(
      BuildContext context, FarmProvider farmProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.water_drop,
              label: 'Irrigation',
              color: const Color(0xFF1B5E20),
              onTap: () {
                setState(() => _currentIndex = 1);
              },
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.analytics,
              label: 'Analytics',
              color: const Color(0xFF1B5E20),
              onTap: () {
                setState(() => _currentIndex = 2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSelector(FarmProvider farmProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: const Color(0xFF1B5E20), size: 20),
              const SizedBox(width: 8),
              Text(
                'Farm & Field Selection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Farm>(
            value: farmProvider.selectedFarm,
            decoration: InputDecoration(
              labelText: 'Select Farm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.agriculture),
            ),
            isExpanded: true,
            items: farmProvider.farms.map((farm) {
              return DropdownMenuItem<Farm>(
                value: farm,
                child: Text(farm.name),
              );
            }).toList(),
            onChanged: (farm) {
              if (farm != null) {
                farmProvider.selectFarm(farm);
              }
            },
          ),
          if (farmProvider.selectedFarm != null &&
              farmProvider.selectedFarm!.fields.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<Field>(
              value: farmProvider.selectedField,
              decoration: InputDecoration(
                labelText: 'Select Field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.grass),
              ),
              isExpanded: true,
              items: farmProvider.selectedFarm!.fields.map((field) {
                return DropdownMenuItem<Field>(
                  value: field,
                  child: Text(field.name),
                );
              }).toList(),
              onChanged: (field) {
                if (field != null) {
                  farmProvider.selectField(field);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(
      BuildContext context, FarmProvider farmProvider) {
    final services = [
      _ServiceItem(
        icon: Icons.water_drop,
        label: 'Irrigation',
        color: Colors.blue,
        onTap: () => setState(() => _currentIndex = 1),
      ),
      _ServiceItem(
        icon: Icons.analytics,
        label: 'Analytics',
        color: Colors.purple,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      _ServiceItem(
        icon: Icons.notifications,
        label: 'Alerts',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlertsScreen()),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.settings,
        label: 'Settings',
        color: Colors.grey,
        onTap: () => setState(() => _currentIndex = 3),
      ),
      _ServiceItem(
        icon: Icons.history,
        label: 'History',
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.devices,
        label: 'Devices',
        color: Colors.indigo,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DevicesScreen()),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.report,
        label: 'Reports',
        color: Colors.red,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportsScreen()),
          );
        },
      ),
      _ServiceItem(
        icon: Icons.help_outline,
        label: 'Help',
        color: Colors.amber,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // View all services
              },
              child: const Text(
                'View All >',
                style: TextStyle(color: Color(0xFF1B5E20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceItem(service);
          },
        ),
      ],
    );
  }

  Widget _buildServiceItem(_ServiceItem service) {
    return InkWell(
      onTap: service.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(service.icon, color: service.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              service.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDataSection(BuildContext context, SensorData sensorData,
      ThresholdSettings thresholds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sensors,
                      color: Color(0xFF1B5E20),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Live Sensor Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Sensor Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount;
            if (width >= 1000) {
              crossAxisCount = 4;
            } else if (width >= 700) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 2;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                SensorCard(
                  title: 'Soil Moisture',
                  value: sensorData.soilMoisture,
                  unit: '%',
                  icon: Icons.water_drop,
                  status: sensorData.soilMoisture <
                              thresholds.minSoilMoisture ||
                          sensorData.soilMoisture > thresholds.maxSoilMoisture
                      ? SensorStatus.critical
                      : sensorData.soilMoisture <
                              thresholds.minSoilMoisture * 1.1
                          ? SensorStatus.warning
                          : SensorStatus.normal,
                  minValue: thresholds.minSoilMoisture,
                  maxValue: thresholds.maxSoilMoisture,
                ),
                SensorCard(
                  title: 'Temperature',
                  value: sensorData.temperature,
                  unit: '°C',
                  icon: Icons.thermostat,
                  status: sensorData.temperature > thresholds.maxTemperature ||
                          sensorData.temperature < thresholds.minTemperature
                      ? SensorStatus.critical
                      : sensorData.temperature > thresholds.maxTemperature * 0.9
                          ? SensorStatus.warning
                          : SensorStatus.normal,
                  minValue: thresholds.minTemperature,
                  maxValue: thresholds.maxTemperature,
                ),
                SensorCard(
                  title: 'Humidity',
                  value: sensorData.humidity,
                  unit: '%',
                  icon: Icons.opacity,
                  status: sensorData.humidity < thresholds.minHumidity ||
                          sensorData.humidity > thresholds.maxHumidity
                      ? SensorStatus.critical
                      : sensorData.humidity < thresholds.minHumidity * 1.1
                          ? SensorStatus.warning
                          : SensorStatus.normal,
                  minValue: thresholds.minHumidity,
                  maxValue: thresholds.maxHumidity,
                ),
                SensorCard(
                  title: 'Light Intensity',
                  value: sensorData.lightIntensity / 1000, // Convert to k lux
                  unit: 'k lux',
                  icon: Icons.light_mode,
                  status: sensorData.lightIntensity <
                          thresholds.minLightIntensity
                      ? SensorStatus.critical
                      : sensorData.lightIntensity <
                              thresholds.minLightIntensity * 1.1
                          ? SensorStatus.warning
                          : SensorStatus.normal,
                  minValue: thresholds.minLightIntensity / 1000,
                  maxValue: thresholds.maxLightIntensity / 1000,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, AlertProvider alertProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                );
              },
              child: const Text(
                'View All >',
                style: TextStyle(color: Color(0xFF1B5E20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (alertProvider.alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No recent alerts',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...alertProvider.alerts.take(3).map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAlertColor(alert.severity).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getAlertIcon(alert.type),
                      color: _getAlertColor(alert.severity),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!alert.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.soilMoisture:
        return Icons.water_drop;
      case AlertType.temperature:
        return Icons.thermostat;
      case AlertType.humidity:
        return Icons.opacity;
      case AlertType.lightIntensity:
        return Icons.light_mode;
      case AlertType.deviceOffline:
        return Icons.wifi_off;
      case AlertType.irrigation:
        return Icons.water_drop;
      case AlertType.system:
        return Icons.info;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Irrigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
