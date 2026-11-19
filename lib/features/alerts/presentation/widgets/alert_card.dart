import 'package:flutter/material.dart';

import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/status_badge.dart';

/// Live alert card (Annex G "Alert Live"): station + asset, date & time, cause_code,
/// Failure/Predictive badge and round buttons Ack · T · PT · F · M · Remark.
class AlertCard extends StatelessWidget {
  final RdpmsAlert alert;
  final VoidCallback onTap;
  final VoidCallback onAck;
  final ValueChanged<AlertFeedback?> onFeedback;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onAck,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final color = alertTypeColor(alert.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${alert.sc}  ${alert.assetNumberCode}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  StatusBadge(text: alert.type.code, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormats.date(alert.incidence)}   ${DateFormats.time(alert.incidence)}'
                '   ·   ${DateFormats.duration(alert.duration)}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(alert.causeCode, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundButton(
                    label: 'Ack',
                    icon: alert.acknowledged ? Icons.check : null,
                    active: alert.acknowledged,
                    onTap: onAck,
                  ),
                  for (final f in AlertFeedback.values)
                    _RoundButton(label: f.code, onTap: () => onFeedback(f)),
                  _RoundButton(label: 'Remark', icon: Icons.edit_note, onTap: () => onFeedback(null)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _RoundButton({required this.label, this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          shape: CircleBorder(side: BorderSide(color: active ? AppColors.healthy : AppColors.border)),
          color: active ? AppColors.healthy.withValues(alpha: 0.1) : Colors.white,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: active ? AppColors.healthy : Colors.black87)
                    : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}
