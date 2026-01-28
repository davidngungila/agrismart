import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<HelpItem> _helpItems = [
    HelpItem(
      category: 'Getting Started',
      items: [
        FAQItem(
          question: 'How do I register an account?',
          answer:
              'Tap on "Register" from the login screen, fill in your details (name, email, phone, password), and submit. Your account will be created and you\'ll be automatically logged in.',
        ),
        FAQItem(
          question: 'How do I select a farm or field?',
          answer:
              'On the dashboard, use the "Farm & Field Selection" dropdown to choose your farm and field. The app will automatically load sensor data for the selected field.',
        ),
        FAQItem(
          question: 'What do the sensor status colors mean?',
          answer:
              'Green (Normal): Values are within safe ranges. Orange (Warning): Values are approaching limits. Red (Critical): Values are outside safe ranges and require attention.',
        ),
      ],
    ),
    HelpItem(
      category: 'Irrigation',
      items: [
        FAQItem(
          question: 'How does automatic irrigation work?',
          answer:
              'In automatic mode, irrigation activates when soil moisture drops below the threshold you set. You can configure the threshold and duration in the Irrigation Control screen.',
        ),
        FAQItem(
          question: 'Can I manually control irrigation?',
          answer:
              'Yes! Switch to "Manual" mode in the Irrigation Control screen, then use the Start/Stop button to control irrigation manually.',
        ),
        FAQItem(
          question: 'What is the recommended soil moisture threshold?',
          answer:
              'The recommended threshold varies by crop type. Generally, 40-50% is good for most crops. Check with your agricultural expert for crop-specific recommendations.',
        ),
      ],
    ),
    HelpItem(
      category: 'Analytics & Reports',
      items: [
        FAQItem(
          question: 'How do I view historical data?',
          answer:
              'Go to the Analytics tab and select a time period (7 days, 30 days, or 90 days). Charts will show trends for all sensor parameters.',
        ),
        FAQItem(
          question: 'What information is in the reports?',
          answer:
              'Reports include summary statistics, detailed min/max/average values, recommendations based on current conditions, and data quality metrics.',
        ),
        FAQItem(
          question: 'Can I export reports?',
          answer:
              'The export feature is coming soon. You\'ll be able to export reports as PDF or CSV files.',
        ),
      ],
    ),
    HelpItem(
      category: 'Alerts & Notifications',
      items: [
        FAQItem(
          question: 'How do I receive alerts?',
          answer:
              'Alerts are automatically generated when sensor values exceed thresholds. You\'ll see notifications in the app and can view all alerts in the Alerts screen.',
        ),
        FAQItem(
          question: 'Can I customize alert thresholds?',
          answer:
              'Yes! Go to Settings > Threshold Settings to customize the minimum and maximum values for each sensor parameter.',
        ),
        FAQItem(
          question: 'What types of alerts are there?',
          answer:
              'Alerts can be for soil moisture, temperature, humidity, light intensity, device offline status, irrigation events, or system notifications.',
        ),
      ],
    ),
    HelpItem(
      category: 'Device Management',
      items: [
        FAQItem(
          question: 'How do I check device status?',
          answer:
              'Go to the Devices screen to see connection status, battery level, sensor connectivity, and last seen time.',
        ),
        FAQItem(
          question: 'What should I do if a device is offline?',
          answer:
              'Check the physical connection, ensure the device has power, and try refreshing the device status. If the problem persists, contact support.',
        ),
        FAQItem(
          question: 'How often does the device send data?',
          answer:
              'By default, sensor data is updated every 2 minutes. You can see the last update time on the dashboard.',
        ),
      ],
    ),
    HelpItem(
      category: 'Troubleshooting',
      items: [
        FAQItem(
          question: 'The app shows "No field selected"',
          answer:
              'Make sure you have selected a farm and field from the dropdown on the dashboard. If no farms are available, contact your administrator.',
        ),
        FAQItem(
          question: 'Sensor data is not updating',
          answer:
              'Check if the device is online in the Devices screen. Try pulling down to refresh the dashboard. If the issue persists, restart the device.',
        ),
        FAQItem(
          question: 'I forgot my password',
          answer:
              'Password recovery is coming soon. For now, please contact support to reset your password.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Card
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
                  const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions below',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Contact Support
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
                        Icon(Icons.support_agent,
                            color: const Color(0xFF1B5E20)),
                        const SizedBox(width: 8),
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      Icons.email,
                      'Email',
                      'support@agrismart.com',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      Icons.phone,
                      'Phone',
                      '+255 622 239 304',
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      Icons.chat,
                      'Live Chat',
                      'Available 24/7',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // FAQ Sections
            ..._helpItems.map((helpItem) => _buildHelpSection(helpItem)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(HelpItem helpItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            helpItem.category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...helpItem.items.map((faq) => _buildFAQItem(faq)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(
          Icons.help_outline,
          color: const Color(0xFF1B5E20),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq.answer,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String category;
  final List<FAQItem> items;

  HelpItem({required this.category, required this.items});
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

