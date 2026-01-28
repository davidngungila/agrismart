import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/irrigation_provider.dart';
import '../models/irrigation_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class IrrigationControlScreen extends StatefulWidget {
  const IrrigationControlScreen({super.key});

  @override
  State<IrrigationControlScreen> createState() =>
      _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _thresholdController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Irrigation Control',
        showNotifications: false,
      ),
      body: Consumer2<FarmProvider, IrrigationProvider>(
        builder: (context, farmProvider, irrigationProvider, _) {
          if (farmProvider.selectedField == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No field selected',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final field = farmProvider.selectedField!;
          final irrigationSettings = field.irrigationSettings;
          final isActive = irrigationProvider.isIrrigationActive(field.id);
          final sensorData = farmProvider.latestSensorData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Overview Card
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
                            child: Icon(
                              isActive ? Icons.water_drop : Icons.water_drop_outlined,
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
                                  'Irrigation Status',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isActive ? 'ACTIVE' : 'INACTIVE',
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
                              color: isActive
                                  ? Colors.green[400]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (sensorData != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Soil Moisture',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${sensorData.soilMoisture.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.water_drop,
                                color: Colors.white.withOpacity(0.8),
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Mode Selection Card
                Card(
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
                            Icon(Icons.settings,
                                color: const Color(0xFF1B5E20)),
                            const SizedBox(width: 8),
                            Text(
                              'Irrigation Mode',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<IrrigationMode>(
                          segments: const [
                            ButtonSegment(
                              value: IrrigationMode.manual,
                              label: Text('Manual'),
                              icon: Icon(Icons.touch_app),
                            ),
                            ButtonSegment(
                              value: IrrigationMode.automatic,
                              label: Text('Automatic'),
                              icon: Icon(Icons.auto_mode),
                            ),
                          ],
                          selected: {irrigationSettings.mode},
                          onSelectionChanged: (Set<IrrigationMode> selection) {
                            final newMode = selection.first;
                            final updatedSettings = IrrigationSettings(
                              mode: newMode,
                              soilMoistureThreshold:
                                  irrigationSettings.soilMoistureThreshold ??
                                      Constants.defaultAutoIrrigationThreshold,
                              durationMinutes:
                                  irrigationSettings.durationMinutes ??
                                      Constants.defaultIrrigationDurationMinutes,
                              isActive: irrigationSettings.isActive,
                            );
                            irrigationProvider.updateIrrigationSettings(
                                field.id, updatedSettings);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Automatic Mode Settings
                if (irrigationSettings.mode == IrrigationMode.automatic) ...[
                  Card(
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
                              Icon(Icons.auto_mode,
                                  color: const Color(0xFF1B5E20)),
                              const SizedBox(width: 8),
                              Text(
                                'Automatic Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _thresholdController
                              ..text = (irrigationSettings.soilMoistureThreshold ??
                                      Constants.defaultAutoIrrigationThreshold)
                                  .toStringAsFixed(1),
                            decoration: InputDecoration(
                              labelText: 'Soil Moisture Threshold (%)',
                              helperText:
                                  'Irrigation activates when moisture drops below this value',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.water_drop),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              final threshold = double.tryParse(value);
                              if (threshold != null) {
                                final updatedSettings = IrrigationSettings(
                                  mode: irrigationSettings.mode,
                                  soilMoistureThreshold: threshold,
                                  durationMinutes:
                                      irrigationSettings.durationMinutes,
                                  isActive: irrigationSettings.isActive,
                                );
                                irrigationProvider.updateIrrigationSettings(
                                    field.id, updatedSettings);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _durationController
                              ..text = (irrigationSettings.durationMinutes ??
                                      Constants.defaultIrrigationDurationMinutes)
                                  .toString(),
                            decoration: InputDecoration(
                              labelText: 'Duration (minutes)',
                              helperText: 'How long irrigation should run',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.timer),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final duration = int.tryParse(value);
                              if (duration != null) {
                                final updatedSettings = IrrigationSettings(
                                  mode: irrigationSettings.mode,
                                  soilMoistureThreshold:
                                      irrigationSettings.soilMoistureThreshold,
                                  durationMinutes: duration,
                                  isActive: irrigationSettings.isActive,
                                );
                                irrigationProvider.updateIrrigationSettings(
                                    field.id, updatedSettings);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Manual Control
                if (irrigationSettings.mode == IrrigationMode.manual) ...[
                  Card(
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
                              Icon(Icons.touch_app,
                                  color: const Color(0xFF1B5E20)),
                              const SizedBox(width: 8),
                              Text(
                                'Manual Control',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: irrigationProvider.isLoading
                                  ? null
                                  : () {
                                      irrigationProvider.controlIrrigation(
                                        field.id,
                                        !isActive,
                                        IrrigationMode.manual,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: isActive
                                    ? Colors.red[600]
                                    : const Color(0xFF1B5E20),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isActive ? Icons.stop : Icons.play_arrow,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isActive
                                        ? 'Stop Irrigation'
                                        : 'Start Irrigation',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Information Card
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
                          irrigationSettings.mode == IrrigationMode.automatic
                              ? 'In automatic mode, irrigation will activate when soil moisture drops below the threshold.'
                              : 'In manual mode, you control irrigation start and stop.',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
