import 'package:flutter/material.dart';

import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Asset-type card: Normal (green) / Failed (red) / Predicted (amber) — Annex G dashboard.
class AssetGroupCard extends StatelessWidget {
  final DashboardGroup group;

  const AssetGroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    Widget line(String label, int v, Color c) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w400),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$v',
              style: TextStyle(
                color: c,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' / ${group.total}',
              style: TextStyle(
                color: c,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(
                children: [
                  Expanded(flex: group.healthy, child: Container(height: 4, color: AppColors.healthy)),
                  Expanded(flex: group.predictive, child: Container(height: 4, color: AppColors.predictive)),
                  Expanded(flex: group.failure, child: Container(height: 4, color: AppColors.failure)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            line('Healthy', group.healthy, AppColors.healthy),
            const SizedBox(height: 4),
            line('Failure', group.failure, AppColors.failure),
            const SizedBox(height: 4),
            line('Predictive', group.predictive, AppColors.predictive),
          ],
        ),
      ),
    );
  }
}
