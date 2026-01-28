import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alert_provider.dart';
import '../models/alert_model.dart';
import '../widgets/custom_app_bar.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alertProvider = Provider.of<AlertProvider>(context, listen: false);
      alertProvider.loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alerts & Notifications',
        showNotifications: false,
        actions: [
          Consumer<AlertProvider>(
            builder: (context, alertProvider, _) {
              if (alertProvider.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () async {
                    for (final alert in alertProvider.unreadAlerts) {
                      await alertProvider.markAsRead(alert.id);
                    }
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          if (alertProvider.isLoading && alertProvider.alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (alertProvider.error != null && alertProvider.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${alertProvider.error}',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => alertProvider.loadAlerts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (alertProvider.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => alertProvider.loadAlerts(),
            child: ListView.builder(
              itemCount: alertProvider.alerts.length,
              itemBuilder: (context, index) {
                final alert = alertProvider.alerts[index];
                return _buildAlertCard(context, alert, alertProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(
      BuildContext context, Alert alert, AlertProvider alertProvider) {
    Color getSeverityColor() {
      switch (alert.severity) {
        case AlertSeverity.critical:
          return Colors.red;
        case AlertSeverity.warning:
          return Colors.orange;
        case AlertSeverity.info:
          return Colors.blue;
      }
    }

    IconData getTypeIcon() {
      switch (alert.type) {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: alert.isRead ? 1 : 3,
      color: alert.isRead ? null : getSeverityColor().withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getSeverityColor().withOpacity(0.2),
          child: Icon(getTypeIcon(), color: getSeverityColor()),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!alert.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getSeverityColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(alert.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            alert.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          ),
          onPressed: () => alertProvider.markAsRead(alert.id),
        ),
        onTap: () {
          if (!alert.isRead) {
            alertProvider.markAsRead(alert.id);
          }
        },
      ),
    );
  }
}

