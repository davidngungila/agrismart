import 'package:flutter/material.dart';

class NetworkSettingsScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const NetworkSettingsScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<NetworkSettingsScreen> createState() => _NetworkSettingsScreenState();
}

class _NetworkSettingsScreenState extends State<NetworkSettingsScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _subnetMaskController = TextEditingController();
  final TextEditingController _gatewayController = TextEditingController();
  final TextEditingController _dnsController = TextEditingController();

  String _connectionType = 'dhcp'; // dhcp or static
  String _securityType = 'WPA2'; // WPA, WPA2, WPA3, None
  bool _autoReconnect = true;
  bool _isConnected = false;
  int _signalStrength = 75; // percentage
  String _currentSSID = 'AgriSmart_Network';

  @override
  void initState() {
    super.initState();
    _loadNetworkSettings();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _ipAddressController.dispose();
    _subnetMaskController.dispose();
    _gatewayController.dispose();
    _dnsController.dispose();
    super.dispose();
  }

  Future<void> _loadNetworkSettings() async {
    // Load network settings from service
    // For now, using default values
    setState(() {
      _ssidController.text = _currentSSID;
      _ipAddressController.text = '192.168.1.100';
      _subnetMaskController.text = '255.255.255.0';
      _gatewayController.text = '192.168.1.1';
      _dnsController.text = '8.8.8.8';
    });
  }

  Future<void> _saveSettings() async {
    // Save network settings
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network settings saved successfully')),
      );
    }
  }

  Future<void> _scanNetworks() async {
    // Simulate network scanning
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scanning for networks...')),
      );
    }
  }

  Future<void> _testConnection() async {
    // Test network connection
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testing connection...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Settings'),
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
            // Connection Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isConnected
                      ? [Colors.green.shade600, Colors.green.shade400]
                      : [Colors.orange.shade600, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected ? 'Connected' : 'Disconnected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isConnected
                              ? 'SSID: $_currentSSID\nSignal: $_signalStrength%'
                              : 'No network connection',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isConnected)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _testConnection,
                      tooltip: 'Test Connection',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Wi-Fi Configuration
            Text(
              'Wi-Fi Configuration',
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
                        const Text(
                          'Scan Networks',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _scanNetworks,
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ssidController,
                      decoration: InputDecoration(
                        labelText: 'Network Name (SSID)',
                        prefixIcon: const Icon(Icons.wifi),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _securityType,
                      decoration: InputDecoration(
                        labelText: 'Security Type',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('None')),
                        DropdownMenuItem(value: 'WPA', child: Text('WPA')),
                        DropdownMenuItem(value: 'WPA2', child: Text('WPA2')),
                        DropdownMenuItem(value: 'WPA3', child: Text('WPA3')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _securityType = value!;
                        });
                      },
                    ),
                    if (_securityType != 'None') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto Reconnect'),
                      subtitle: const Text(
                        'Automatically reconnect when network is available',
                      ),
                      value: _autoReconnect,
                      onChanged: (value) {
                        setState(() {
                          _autoReconnect = value;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // IP Configuration
            Text(
              'IP Configuration',
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
                    RadioListTile<String>(
                      title: const Text('DHCP (Automatic)'),
                      subtitle: const Text('Obtain IP address automatically'),
                      value: 'dhcp',
                      groupValue: _connectionType,
                      onChanged: (value) {
                        setState(() {
                          _connectionType = value!;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Static IP'),
                      subtitle: const Text('Configure IP address manually'),
                      value: 'static',
                      groupValue: _connectionType,
                      onChanged: (value) {
                        setState(() {
                          _connectionType = value!;
                        });
                      },
                      activeColor: const Color(0xFF1B5E20),
                    ),
                    if (_connectionType == 'static') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ipAddressController,
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          prefixIcon: const Icon(Icons.computer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _subnetMaskController,
                        decoration: InputDecoration(
                          labelText: 'Subnet Mask',
                          prefixIcon: const Icon(Icons.network_check),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _gatewayController,
                        decoration: InputDecoration(
                          labelText: 'Gateway',
                          prefixIcon: const Icon(Icons.router),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dnsController,
                        decoration: InputDecoration(
                          labelText: 'DNS Server',
                          prefixIcon: const Icon(Icons.dns),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
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
                  'Save Network Settings',
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
}

