import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/status_badge.dart';

/// Alert History (Annex E §7.2): all alerts for selected duration & fields.
class AlertHistoryTab extends StatefulWidget {
  const AlertHistoryTab({super.key});

  @override
  State<AlertHistoryTab> createState() => _AlertHistoryTabState();
}

class _AlertHistoryTabState extends State<AlertHistoryTab> {
  LocationFilter _location = const LocationFilter();
  DateTimeRange _range = defaultRange(30);
  AlertType? _type;
  AlertFeedback? _feedback;
  AlertType? _appliedType;
  AlertFeedback? _appliedFeedback;

  @override
  Widget build(BuildContext context) {
    final alerts = MockData.alerts
        .where((a) => _location.matches(zc: a.zc, dc: a.dc, sc: a.sc))
        .where((a) => _appliedType == null || a.type == _appliedType)
        .where((a) => _appliedFeedback == null || a.feedback == _appliedFeedback)
        .where((a) => !a.incidence.isBefore(_range.start))
        .toList()
      ..sort((a, b) => b.incidence.compareTo(a.incidence));

    return ListView(
      children: [
        FilterBar(
          extraFilters: [
            AppDropdown<AlertType>(
              label: 'Alert type',
              value: _type,
              items: AlertType.values,
              itemLabel: (t) => t.code,
              onChanged: (v) => setState(() => _type = v),
            ),
            AppDropdown<AlertFeedback>(
              label: 'Feedback',
              value: _feedback,
              items: AlertFeedback.values,
              itemLabel: (f) => f.code,
              onChanged: (v) => setState(() => _feedback = v),
            ),
            DateRangeButton(range: _range, onChanged: (r) => setState(() => _range = r)),
          ],
          onSearch: (loc) => setState(() {
            _location = loc;
            _appliedType = _type;
            _appliedFeedback = _feedback;
          }),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle('${alerts.length} alerts', trailing: const DownloadButton()),
              if (alerts.isEmpty) const EmptyState('No alerts in this period'),
              ...alerts.map((a) => _HistoryTile(alert: a)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final RdpmsAlert alert;
  const _HistoryTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final a = alert;
    final cleared = a.status == AlertStatus.cleared;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RouteNames.alertDetail(a.id)),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${a.zc} / ${a.dc} / ${a.sc}  ·  ${a.assetNumberCode}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  StatusBadge(text: a.type.code, color: alertTypeColor(a.type)),
                ],
              ),
              const SizedBox(height: 4),
              Text(a.causeCode, style: TextStyle(color: alertTypeColor(a.type), fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _kv('Incidence', DateFormats.dateTime(a.incidence)),
                  _kv('Rectified', a.rectification == null ? '-----' : DateFormats.dateTime(a.rectification!)),
                  _kv('Duration', DateFormats.duration(a.duration)),
                  _kv('Status', a.status.code),
                  _kv('Feedback', a.feedback?.code ?? '---'),
                  if (cleared) _kv('Maintainer', '${a.maintainerName} (${a.maintainerDesignation})'),
                ],
              ),
              if (a.remarks != null) ...[
                const SizedBox(height: 6),
                Text('Remarks: ${a.remarks}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(text: '$k: ', style: const TextStyle(color: AppColors.neutral)),
            TextSpan(text: v, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
