import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/audit_event.dart';

/// Audit log tab (Annex D §19; web design W22): unauthorised access attempts to
/// the RDPMS application, Station Gateway and IoT, plus logged admin changes.
/// Filter by result: All · Blocked · Warned · Logged.
class AuditLogTab extends StatefulWidget {
  final List<AuditEvent> events;
  const AuditLogTab({super.key, required this.events});

  @override
  State<AuditLogTab> createState() => _AuditLogTabState();
}

class _AuditLogTabState extends State<AuditLogTab> {
  AuditResult? _result;

  @override
  Widget build(BuildContext context) {
    final shown = widget.events
        .where((e) => _result == null || e.result == _result)
        .toList();
    int count(AuditResult r) =>
        widget.events.where((e) => e.result == r).length;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        const Text(
          'Unauthorised access to the RDPMS application, Station Gateway and IoT (Annex D §19), '
          'and admin changes.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('All · ${widget.events.length}'),
              selected: _result == null,
              onSelected: (_) => setState(() => _result = null),
            ),
            for (final r in AuditResult.values)
              ChoiceChip(
                label: Text('${r.label} · ${count(r)}'),
                selected: _result == r,
                onSelected: (_) => setState(() => _result = r),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (shown.isEmpty)
          const EmptyState(
            'No audit events',
            icon: Icons.verified_user_outlined,
          )
        else
          for (final e in shown) _AuditCard(event: e),
      ],
    );
  }
}

class _AuditCard extends StatelessWidget {
  final AuditEvent event;
  const _AuditCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (event.result) {
      AuditResult.blocked => (
        AppColors.failureSoft,
        AppColors.failure,
        Icons.gpp_bad_outlined,
      ),
      AuditResult.warned => (
        AppColors.predictiveSoft,
        AppColors.predictiveText,
        Icons.gpp_maybe_outlined,
      ),
      AuditResult.logged => (
        AppColors.neutralSoft,
        AppColors.textLabel,
        Icons.history,
      ),
    };
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.event,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.result.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.userId} · ${event.device}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${event.source} · ${DateFormats.dateTime(event.time)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
