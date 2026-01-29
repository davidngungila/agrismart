import 'package:flutter/material.dart';

class TimeSettingsScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const TimeSettingsScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<TimeSettingsScreen> createState() => _TimeSettingsScreenState();
}

class _TimeSettingsScreenState extends State<TimeSettingsScreen> {
  bool _autoSync = true;
  String _timezone = 'UTC';
  String _ntpServer = 'pool.ntp.org';
  int _syncInterval = 24; // hours
  bool _daylightSaving = false;
  DateTime _currentDeviceTime = DateTime.now();
  DateTime? _lastSyncTime;

  final List<String> _timezones = [
    'UTC',
    'GMT',
    'EST (UTC-5)',
    'PST (UTC-8)',
    'CST (UTC-6)',
    'IST (UTC+5:30)',
    'JST (UTC+9)',
    'CET (UTC+1)',
    'AEST (UTC+10)',
  ];

  final List<String> _ntpServers = [
    'pool.ntp.org',
    'time.google.com',
    'time.cloudflare.com',
    'time.windows.com',
    'time.nist.gov',
  ];

  @override
  void initState() {
    super.initState();
    _loadTimeSettings();
    _updateCurrentTime();
  }

  void _updateCurrentTime() {
    setState(() {
      _currentDeviceTime = DateTime.now();
    });
    // Update time every second
    Future.delayed(const Duration(seconds: 1), _updateCurrentTime);
  }

  Future<void> _loadTimeSettings() async {
    // Load time settings from service
    setState(() {
      _lastSyncTime = DateTime.now().subtract(const Duration(hours: 2));
    });
  }

  Future<void> _saveSettings() async {
    // Save time settings
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time settings saved successfully')),
      );
    }
  }

  Future<void> _syncTimeNow() async {
    // Sync time with NTP server
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncTime = DateTime.now();
        _currentDeviceTime = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time synchronized successfully')),
      );
    }
  }

  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Settings'),
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
            // Current Time Card
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
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentDeviceTime.year}-${_currentDeviceTime.month.toString().padLeft(2, '0')}-${_currentDeviceTime.day.toString().padLeft(2, '0')} ${_currentDeviceTime.hour.toString().padLeft(2, '0')}:${_currentDeviceTime.minute.toString().padLeft(2, '0')}:${_currentDeviceTime.second.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_lastSyncTime != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last sync: ${_formatDateTime(_lastSyncTime!)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Time Sync Settings
            Text(
              'Time Synchronization',
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
                      title: const Text('Auto Sync'),
                      subtitle: const Text(
                        'Automatically sync time with NTP server',
                      ),
                      value: _autoSync,
                      onChanged: (value) {
                        setState(() {
                          _autoSync = value;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                    if (_autoSync) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sync Interval',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Every $_syncInterval hours',
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
                        value: _syncInterval.toDouble(),
                        min: 1,
                        max: 168, // 1 week
                        divisions: 167,
                        label: '$_syncInterval hours',
                        onChanged: (value) {
                          setState(() {
                            _syncInterval = value.toInt();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _ntpServer,
                      decoration: InputDecoration(
                        labelText: 'NTP Server',
                        prefixIcon: const Icon(Icons.cloud),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _ntpServers.map((server) {
                        return DropdownMenuItem(
                          value: server,
                          child: Text(server),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _ntpServer = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncTimeNow,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Timezone Settings
            Text(
              'Timezone Settings',
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
                    DropdownButtonFormField<String>(
                      value: _timezone,
                      decoration: InputDecoration(
                        labelText: 'Timezone',
                        prefixIcon: const Icon(Icons.language),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _timezones.map((tz) {
                        return DropdownMenuItem(
                          value: tz,
                          child: Text(tz),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _timezone = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Daylight Saving Time'),
                      subtitle: const Text(
                        'Automatically adjust for daylight saving time',
                      ),
                      value: _daylightSaving,
                      onChanged: (value) {
                        setState(() {
                          _daylightSaving = value;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                  ],
                ),
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
                  'Save Time Settings',
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

