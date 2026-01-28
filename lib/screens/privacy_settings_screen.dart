import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataCollection = true;
  bool _analytics = true;
  bool _crashReports = false;
  bool _shareData = false;
  bool _locationTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
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
            // Privacy Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.blue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Control how your data is collected and used. Your privacy is important to us.',
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
            // Data Collection
            Text(
              'Data Collection',
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
                  SwitchListTile(
                    title: const Text('Data Collection'),
                    subtitle: const Text(
                      'Allow collection of sensor and usage data',
                    ),
                    value: _dataCollection,
                    onChanged: (value) {
                      setState(() {
                        _dataCollection = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Analytics'),
                    subtitle: const Text(
                      'Help improve the app by sharing usage analytics',
                    ),
                    value: _analytics,
                    onChanged: (value) {
                      setState(() {
                        _analytics = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Crash Reports'),
                    subtitle: const Text(
                      'Automatically send crash reports for debugging',
                    ),
                    value: _crashReports,
                    onChanged: (value) {
                      setState(() {
                        _crashReports = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Location & Sharing
            Text(
              'Location & Sharing',
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
                  SwitchListTile(
                    title: const Text('Location Tracking'),
                    subtitle: const Text(
                      'Allow location tracking for farm mapping',
                    ),
                    value: _locationTracking,
                    onChanged: (value) {
                      setState(() {
                        _locationTracking = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Share Data with Partners'),
                    subtitle: const Text(
                      'Allow sharing anonymized data with research partners',
                    ),
                    value: _shareData,
                    onChanged: (value) {
                      setState(() {
                        _shareData = value;
                      });
                    },
                    activeColor: const Color(0xFF1B5E20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Privacy Actions
            Text(
              'Privacy Actions',
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
                    leading: const Icon(Icons.download, color: Colors.blue),
                    title: const Text('Download My Data'),
                    subtitle: const Text('Request a copy of your data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data download request sent'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete My Account'),
                    subtitle: const Text('Permanently delete your account and data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
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
                  'Save Privacy Settings',
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

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings saved')),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'WARNING: This will permanently delete your account and all associated data. This action cannot be undone. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

