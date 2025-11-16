import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service'), elevation: 0),
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
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terms of Service',
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

            // Terms Content
            _buildSection(
              context,
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using FlexBiller, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily use FlexBiller for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to reverse engineer any software\n• Remove any copyright or other proprietary notations',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '3. User Account',
              content:
                  'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '4. Data and Privacy',
              content:
                  'Your use of FlexBiller is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices regarding the collection and use of your information.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '5. Limitation of Liability',
              content:
                  'In no event shall FlexBiller or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use FlexBiller.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '6. Revisions',
              content:
                  'FlexBiller may revise these terms of service at any time without notice. By using this application you are agreeing to be bound by the then current version of these terms of service.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '7. Contact Information',
              content:
                  'If you have any questions about these Terms of Service, please contact us at:\n\nEmail: legal@flexbiller.com\nPhone: +1 (555) 123-4567',
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

