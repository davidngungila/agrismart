import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../services/local_data_service.dart';
import '../models/threshold_model.dart';

class ThresholdSettingsScreen extends StatefulWidget {
  const ThresholdSettingsScreen({super.key});

  @override
  State<ThresholdSettingsScreen> createState() =>
      _ThresholdSettingsScreenState();
}

class _ThresholdSettingsScreenState extends State<ThresholdSettingsScreen> {
  final LocalDataService _dataService = LocalDataService();
  ThresholdSettings? _thresholdSettings;
  bool _isLoading = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadThresholdSettings();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadThresholdSettings() async {
    setState(() => _isLoading = true);

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.selectedField != null) {
        _thresholdSettings = await _dataService
            .getThresholdSettings(farmProvider.selectedField!.id);
        _initializeControllers();
      } else {
        _thresholdSettings = ThresholdSettings();
        _initializeControllers();
      }
    } catch (e) {
      _thresholdSettings = ThresholdSettings();
      _initializeControllers();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    if (_thresholdSettings == null) return;

    _controllers['minSoilMoisture'] = TextEditingController(
        text: _thresholdSettings!.minSoilMoisture.toStringAsFixed(1));
    _controllers['maxSoilMoisture'] = TextEditingController(
        text: _thresholdSettings!.maxSoilMoisture.toStringAsFixed(1));
    _controllers['minTemperature'] = TextEditingController(
        text: _thresholdSettings!.minTemperature.toStringAsFixed(1));
    _controllers['maxTemperature'] = TextEditingController(
        text: _thresholdSettings!.maxTemperature.toStringAsFixed(1));
    _controllers['minHumidity'] = TextEditingController(
        text: _thresholdSettings!.minHumidity.toStringAsFixed(1));
    _controllers['maxHumidity'] = TextEditingController(
        text: _thresholdSettings!.maxHumidity.toStringAsFixed(1));
    _controllers['minLightIntensity'] = TextEditingController(
        text: _thresholdSettings!.minLightIntensity.toStringAsFixed(0));
    _controllers['maxLightIntensity'] = TextEditingController(
        text: _thresholdSettings!.maxLightIntensity.toStringAsFixed(0));
  }

  Future<void> _saveThresholdSettings() async {
    if (_thresholdSettings == null) return;

    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.selectedField == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No field selected')),
        );
        return;
      }

      final updatedSettings = ThresholdSettings(
        minSoilMoisture: double.tryParse(_controllers['minSoilMoisture']!.text) ??
            _thresholdSettings!.minSoilMoisture,
        maxSoilMoisture: double.tryParse(_controllers['maxSoilMoisture']!.text) ??
            _thresholdSettings!.maxSoilMoisture,
        minTemperature: double.tryParse(_controllers['minTemperature']!.text) ??
            _thresholdSettings!.minTemperature,
        maxTemperature: double.tryParse(_controllers['maxTemperature']!.text) ??
            _thresholdSettings!.maxTemperature,
        minHumidity: double.tryParse(_controllers['minHumidity']!.text) ??
            _thresholdSettings!.minHumidity,
        maxHumidity: double.tryParse(_controllers['maxHumidity']!.text) ??
            _thresholdSettings!.maxHumidity,
        minLightIntensity:
            double.tryParse(_controllers['minLightIntensity']!.text) ??
                _thresholdSettings!.minLightIntensity,
        maxLightIntensity:
            double.tryParse(_controllers['maxLightIntensity']!.text) ??
                _thresholdSettings!.maxLightIntensity,
      );

      await _dataService.updateThresholdSettings(
          farmProvider.selectedField!.id, updatedSettings);

      setState(() {
        _thresholdSettings = updatedSettings;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Threshold settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threshold Settings'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveThresholdSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: const Color(0xFF1B5E20)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Set minimum and maximum values for each sensor parameter. Alerts will be triggered when values exceed these thresholds.',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_thresholdSettings != null) ...[
                    // Soil Moisture
                    _buildThresholdSection(
                      'Soil Moisture',
                      Icons.water_drop,
                      Colors.blue,
                      'minSoilMoisture',
                      'maxSoilMoisture',
                      '%',
                    ),
                    const SizedBox(height: 20),
                    // Temperature
                    _buildThresholdSection(
                      'Temperature',
                      Icons.thermostat,
                      Colors.orange,
                      'minTemperature',
                      'maxTemperature',
                      '°C',
                    ),
                    const SizedBox(height: 20),
                    // Humidity
                    _buildThresholdSection(
                      'Humidity',
                      Icons.opacity,
                      Colors.green,
                      'minHumidity',
                      'maxHumidity',
                      '%',
                    ),
                    const SizedBox(height: 20),
                    // Light Intensity
                    _buildThresholdSection(
                      'Light Intensity',
                      Icons.light_mode,
                      Colors.amber,
                      'minLightIntensity',
                      'maxLightIntensity',
                      'lux',
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveThresholdSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save All Settings',
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

  Widget _buildThresholdSection(
    String title,
    IconData icon,
    Color color,
    String minKey,
    String maxKey,
    String unit,
  ) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
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
                  child: TextField(
                    controller: _controllers[minKey],
                    decoration: InputDecoration(
                      labelText: 'Minimum ($unit)',
                      prefixIcon: Icon(Icons.arrow_downward, color: color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controllers[maxKey],
                    decoration: InputDecoration(
                      labelText: 'Maximum ($unit)',
                      prefixIcon: Icon(Icons.arrow_upward, color: color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


