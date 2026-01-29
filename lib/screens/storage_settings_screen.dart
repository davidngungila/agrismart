import 'package:flutter/material.dart';

class StorageSettingsScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const StorageSettingsScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  int _totalStorage = 16384; // MB (16 GB)
  int _usedStorage = 5120; // MB (5 GB)
  int _availableStorage = 11264; // MB (11 GB)
  int _dataRetentionDays = 30;
  bool _autoCleanup = true;
  int _cleanupThreshold = 80; // percentage
  String _storageLocation = 'Internal';
  bool _enableBackup = false;
  int _backupInterval = 24; // hours

  @override
  void initState() {
    super.initState();
    _loadStorageSettings();
  }

  Future<void> _loadStorageSettings() async {
    // Load storage settings from service
    // For now, using default values
  }

  Future<void> _saveSettings() async {
    // Save storage settings
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage settings saved successfully')),
      );
    }
  }

  Future<void> _clearCache() async {
    // Clear device cache
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear all cached data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Simulate clearing cache
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    }
  }

  Future<void> _formatStorage() async {
    // Format storage (dangerous operation)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Format Storage'),
        content: const Text(
          'WARNING: This will erase all data on the device storage. This action cannot be undone. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Format',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format operation initiated'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storagePercentage = (_usedStorage / _totalStorage) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Settings'),
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
            // Storage Overview Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storage,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Storage Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatSize(_usedStorage)} / ${_formatSize(_totalStorage)} used',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: storagePercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        storagePercentage > 80
                            ? Colors.red.shade300
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${storagePercentage.toStringAsFixed(1)}% used',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_formatSize(_availableStorage)} available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Data Retention Settings
            Text(
              'Data Retention',
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Retention Period',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Keep data for $_dataRetentionDays days',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _dataRetentionDays.toDouble(),
                      min: 7,
                      max: 365,
                      divisions: 358,
                      label: '$_dataRetentionDays days',
                      onChanged: (value) {
                        setState(() {
                          _dataRetentionDays = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto Cleanup'),
                      subtitle: const Text(
                        'Automatically delete old data when storage is full',
                      ),
                      value: _autoCleanup,
                      onChanged: (value) {
                        setState(() {
                          _autoCleanup = value;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                    if (_autoCleanup) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cleanup Threshold',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Start cleanup at $_cleanupThreshold%',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _cleanupThreshold.toDouble(),
                        min: 50,
                        max: 95,
                        divisions: 45,
                        label: '$_cleanupThreshold%',
                        onChanged: (value) {
                          setState(() {
                            _cleanupThreshold = value.toInt();
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Backup Settings
            Text(
              'Backup Settings',
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Backup'),
                      subtitle: const Text(
                        'Automatically backup data to cloud storage',
                      ),
                      value: _enableBackup,
                      onChanged: (value) {
                        setState(() {
                          _enableBackup = value;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                    if (_enableBackup) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Backup Interval',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Backup every $_backupInterval hours',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _backupInterval.toDouble(),
                        min: 1,
                        max: 168, // 1 week
                        divisions: 167,
                        label: '$_backupInterval hours',
                        onChanged: (value) {
                          setState(() {
                            _backupInterval = value.toInt();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _storageLocation,
                      decoration: InputDecoration(
                        labelText: 'Storage Location',
                        prefixIcon: const Icon(Icons.folder),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Internal',
                          child: Text('Internal Storage'),
                        ),
                        DropdownMenuItem(
                          value: 'SD Card',
                          child: Text('SD Card'),
                        ),
                        DropdownMenuItem(
                          value: 'External',
                          child: Text('External Drive'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _storageLocation = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Storage Actions
            Text(
              'Storage Actions',
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
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.orange),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Remove temporary files and cache'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _clearCache,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.format_clear, color: Colors.red),
                    title: const Text('Format Storage'),
                    subtitle: const Text('Erase all data (dangerous)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _formatStorage,
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
                  'Save Storage Settings',
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

  String _formatSize(int sizeInMB) {
    if (sizeInMB < 1024) {
      return '$sizeInMB MB';
    } else {
      final sizeInGB = sizeInMB / 1024;
      return '${sizeInGB.toStringAsFixed(2)} GB';
    }
  }
}

