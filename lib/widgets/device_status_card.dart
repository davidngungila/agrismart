import 'package:flutter/material.dart';
import '../models/sensor_data_model.dart';
import '../utils/constants.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceStatus deviceStatus;

  const DeviceStatusCard({
    super.key,
    required this.deviceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  deviceStatus.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: deviceStatus.isOnline
                      ? const Color(Constants.colorNormal)
                      : const Color(Constants.colorOffline),
                ),
                const SizedBox(width: 8),
                Text(
                  'Device Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              context,
              'Connection',
              deviceStatus.isOnline ? 'Online' : 'Offline',
              deviceStatus.isOnline
                  ? const Color(Constants.colorNormal)
                  : const Color(Constants.colorOffline),
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              context,
              'Sensors',
              deviceStatus.sensorConnected ? 'Connected' : 'Disconnected',
              deviceStatus.sensorConnected
                  ? const Color(Constants.colorNormal)
                  : const Color(Constants.colorCritical),
            ),
            if (deviceStatus.batteryLevel != null) ...[
              const SizedBox(height: 8),
              _buildStatusRow(
                context,
                'Battery',
                '${deviceStatus.batteryLevel}%',
                _getBatteryColor(deviceStatus.batteryLevel!),
              ),
            ],
            if (deviceStatus.lastSeen != null) ...[
              const SizedBox(height: 8),
              _buildStatusRow(
                context,
                'Last Seen',
                _formatLastSeen(deviceStatus.lastSeen!),
                Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return const Color(Constants.colorNormal);
    if (level > 20) return const Color(Constants.colorWarning);
    return const Color(Constants.colorCritical);
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

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

