import 'package:flutter/material.dart';

import '../mock/mock_models.dart';
import '../theme/app_colors.dart';

Color statusColor(AssetStatus s) => switch (s) {
      AssetStatus.healthy => AppColors.healthy,
      AssetStatus.predictive => AppColors.predictive,
      AssetStatus.failure => AppColors.failure,
    };

String statusLabel(AssetStatus s) => switch (s) {
      AssetStatus.healthy => 'Healthy',
      AssetStatus.predictive => 'Predictive',
      AssetStatus.failure => 'Failure',
    };

Color alertTypeColor(AlertType t) =>
    t == AlertType.failure ? AppColors.failure : AppColors.predictive;

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const StatusBadge({super.key, required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
