import 'package:flutter/material.dart';

import '../../domain/entities/plan_feature.dart';

class PlanFeatureListWidget extends StatelessWidget {
  final List<PlanFeature> features;

  const PlanFeatureListWidget({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features
          .map((feature) => _buildFeatureItem(context, feature))
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature.featureName,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            feature.featureValue,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

