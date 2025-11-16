import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Content
            _buildSection(
              context,
              title: '1. Information We Collect',
              content:
                  'We collect information that you provide directly to us, including:\n\n• Account information (name, email, phone number)\n• Business data (accounts, invoices, payments, subscriptions)\n• Usage data (how you interact with the app)\n• Device information (device type, operating system)',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send technical notices and support messages\n• Respond to your comments and questions\n• Monitor and analyze trends and usage',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '3. Data Storage and Security',
              content:
                  'We implement appropriate technical and organizational measures to protect your personal information. Your data is stored securely using encryption and secure storage protocols. We use local-first architecture, meaning your data is stored locally on your device and synced securely with our servers.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '4. Data Sharing',
              content:
                  'We do not sell, trade, or rent your personal information to third parties. We may share your information only:\n\n• With your consent\n• To comply with legal obligations\n• To protect our rights and safety\n• With service providers who assist us in operating our service',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '5. Your Rights',
              content:
                  'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Data portability\n• Withdraw consent at any time',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '6. Cookies and Tracking',
              content:
                  'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '7. Children\'s Privacy',
              content:
                  'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '8. Changes to This Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '9. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@flexbiller.com\nPhone: +1 (555) 123-4567\nAddress: 123 Business St, Suite 100, City, State 12345',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

