import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../providers/irrigation_provider.dart';
import '../services/local_data_service.dart';
import '../models/irrigation_model.dart';
import '../models/sensor_data_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalDataService _dataService = LocalDataService();
  String _selectedTab = 'irrigation'; // irrigation, sensor, alerts
  List<IrrigationHistory> _irrigationHistory = [];
  List<SensorData> _sensorHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.selectedField == null) {
        setState(() => _isLoading = false);
        return;
      }

      final irrigationProvider =
          Provider.of<IrrigationProvider>(context, listen: false);
      _irrigationHistory = await irrigationProvider.getIrrigationHistory(
        farmProvider.selectedField!.id,
      );

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      _sensorHistory = await _dataService.getHistoricalSensorData(
        farmProvider.selectedField!.id,
        startDate,
        now,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('irrigation', 'Irrigation'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('sensor', 'Sensor Data'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('alerts', 'Alerts'),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = _selectedTab == tab;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'irrigation':
        return _buildIrrigationHistory();
      case 'sensor':
        return _buildSensorHistory();
      case 'alerts':
        return _buildAlertsHistory();
      default:
        return _buildIrrigationHistory();
    }
  }

  Widget _buildIrrigationHistory() {
    if (_irrigationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No irrigation history',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<IrrigationHistory>>{};
    for (var item in _irrigationHistory) {
      final dateKey = DateFormat('MMM dd, yyyy').format(item.startTime);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final items = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            ...items.map((item) => _buildIrrigationHistoryItem(item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildIrrigationHistoryItem(IrrigationHistory item) {
    final duration = item.endTime != null
        ? item.endTime!.difference(item.startTime)
        : const Duration(minutes: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.water_drop, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Irrigation ${item.mode == IrrigationMode.automatic ? '(Auto)' : '(Manual)'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(item.startTime)} - ${item.endTime != null ? DateFormat('HH:mm').format(item.endTime!) : 'Ongoing'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (item.triggeredBy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Triggered by: ${item.triggeredBy}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${duration.inMinutes} min',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
              if (item.soilMoistureBefore != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${item.soilMoistureBefore!.toStringAsFixed(1)}% → ${item.soilMoistureAfter?.toStringAsFixed(1) ?? "N/A"}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorHistory() {
    if (_sensorHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No sensor data history',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<SensorData>>{};
    for (var item in _sensorHistory) {
      final dateKey = DateFormat('MMM dd, yyyy').format(item.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final items = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            ...items.take(10).map((item) => _buildSensorHistoryItem(item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSensorHistoryItem(SensorData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm:ss').format(item.timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSensorValue('Soil', '${item.soilMoisture.toStringAsFixed(1)}%', Icons.water_drop, Colors.blue),
              _buildSensorValue('Temp', '${item.temperature.toStringAsFixed(1)}°C', Icons.thermostat, Colors.orange),
              _buildSensorValue('Humidity', '${item.humidity.toStringAsFixed(1)}%', Icons.opacity, Colors.green),
              _buildSensorValue('Light', '${(item.lightIntensity / 1000).toStringAsFixed(0)}k', Icons.light_mode, Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorValue(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Alert history will be shown here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

