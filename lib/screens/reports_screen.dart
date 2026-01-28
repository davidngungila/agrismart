import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../services/local_data_service.dart';
import '../models/sensor_data_model.dart';
import '../models/threshold_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final LocalDataService _dataService = LocalDataService();
  String _selectedPeriod = '7d';
  List<SensorData> _historicalData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.selectedField == null) {
        setState(() => _isLoading = false);
        return;
      }

      final now = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case '7d':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '90d':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      _historicalData = await _dataService.getHistoricalSensorData(
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
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historicalData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No data available for report',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Selector
                      Card(
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
                                  Icon(Icons.calendar_today,
                                      color: const Color(0xFF1B5E20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Report Period',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: '7d',
                                    label: Text('7 Days'),
                                  ),
                                  ButtonSegment(
                                    value: '30d',
                                    label: Text('30 Days'),
                                  ),
                                  ButtonSegment(
                                    value: '90d',
                                    label: Text('90 Days'),
                                  ),
                                ],
                                selected: {_selectedPeriod},
                                onSelectionChanged: (Set<String> selection) {
                                  setState(() {
                                    _selectedPeriod = selection.first;
                                  });
                                  _loadReportData();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Summary Statistics
                      _buildSummarySection(),
                      const SizedBox(height: 20),
                      // Detailed Statistics
                      _buildDetailedStats(),
                      const SizedBox(height: 20),
                      // Recommendations
                      _buildRecommendations(),
                      const SizedBox(height: 20),
                      // Data Quality
                      _buildDataQuality(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummarySection() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    final avgSoil = _historicalData.map((e) => e.soilMoisture).reduce((a, b) => a + b) / _historicalData.length;
    final avgTemp = _historicalData.map((e) => e.temperature).reduce((a, b) => a + b) / _historicalData.length;
    final avgHumidity = _historicalData.map((e) => e.humidity).reduce((a, b) => a + b) / _historicalData.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: const Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Text(
                  'Summary Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Soil Moisture',
                    '${avgSoil.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Temperature',
                    '${avgTemp.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Humidity',
                    '${avgHumidity.toStringAsFixed(1)}%',
                    Icons.opacity,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Data Points',
                    '${_historicalData.length}',
                    Icons.data_usage,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    final soilValues = _historicalData.map((e) => e.soilMoisture).toList();
    final tempValues = _historicalData.map((e) => e.temperature).toList();
    final humidityValues = _historicalData.map((e) => e.humidity).toList();

    soilValues.sort();
    tempValues.sort();
    humidityValues.sort();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: const Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Text(
                  'Detailed Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow('Soil Moisture', soilValues, '%'),
            const SizedBox(height: 12),
            _buildStatRow('Temperature', tempValues, '°C'),
            const SizedBox(height: 12),
            _buildStatRow('Humidity', humidityValues, '%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, List<double> values, String unit) {
    final min = values.first;
    final max = values.last;
    final avg = values.reduce((a, b) => a + b) / values.length;
    final median = values[values.length ~/ 2];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Min', '${min.toStringAsFixed(1)}$unit'),
              ),
              Expanded(
                child: _buildMiniStat('Max', '${max.toStringAsFixed(1)}$unit'),
              ),
              Expanded(
                child: _buildMiniStat('Avg', '${avg.toStringAsFixed(1)}$unit'),
              ),
              Expanded(
                child: _buildMiniStat('Median', '${median.toStringAsFixed(1)}$unit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
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

  Widget _buildRecommendations() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    final thresholds = ThresholdSettings();
    final latest = _historicalData.last;
    final recommendations = <String>[];

    if (latest.soilMoisture < thresholds.minSoilMoisture) {
      recommendations.add('Soil moisture is low. Consider irrigation.');
    }
    if (latest.temperature > thresholds.maxTemperature) {
      recommendations.add('Temperature is high. Monitor crop stress.');
    }
    if (latest.humidity < thresholds.minHumidity) {
      recommendations.add('Humidity is low. Consider misting or shading.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All parameters are within normal range.');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: const Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDataQuality() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    final totalPoints = _historicalData.length;
    final onlinePoints = _historicalData
        .where((e) => e.deviceStatus.isOnline)
        .length;
    final quality = (onlinePoints / totalPoints * 100);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: const Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Text(
                  'Data Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Reliability',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${quality.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: quality > 90 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: quality / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  quality > 90 ? Colors.green : Colors.orange,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Data Points',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Online Points',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$onlinePoints',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report export feature coming soon'),
      ),
    );
  }
}

