import 'package:flutter/material.dart';
import '../../../core/utils/build_info.dart';

/// A page that displays version information and build details
class VersionInfoPage extends StatelessWidget {
  const VersionInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Version Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main version card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FlexBiller',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      BuildInfo.displayVersion,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Build ${BuildInfo.buildNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detailed information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, 'Version Name', BuildInfo.version),
                    _buildInfoRow(
                      context,
                      'Version Code',
                      BuildInfo.buildNumber,
                    ),
                    _buildInfoRow(context, 'Git Commit', BuildInfo.gitCommit),
                    _buildInfoRow(
                      context,
                      'Build Type',
                      BuildInfo.isDebugBuild ? 'Debug' : 'Release',
                    ),
                    if (BuildInfo.isDebugBuild) ...[
                      _buildInfoRow(context, 'Build Time', BuildInfo.buildTime),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Semantic version breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semantic Version',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Major',
                      BuildInfo.majorVersion.toString(),
                    ),
                    _buildInfoRow(
                      context,
                      'Minor',
                      BuildInfo.minorVersion.toString(),
                    ),
                    _buildInfoRow(
                      context,
                      'Patch',
                      BuildInfo.patchVersion.toString(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Debug information (only for debug builds)
            if (BuildInfo.isDebugBuild) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bug_report, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Debug Information',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        BuildInfo.detailedVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Footer
            Center(
              child: Text(
                'FlexBiller - Billing & Subscription Management',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: value == BuildInfo.gitCommit ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
