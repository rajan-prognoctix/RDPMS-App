import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/bloc/auth_context.dart';
import '../widgets/feedback_sheet.dart';

/// Detailed technical information shown when an alert is tapped (Annex D §1).
class AlertDetailPage extends StatefulWidget {
  final String alertId;
  const AlertDetailPage({super.key, required this.alertId});

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  @override
  Widget build(BuildContext context) {
    final a = MockData.alertById(widget.alertId);
    if (a == null) {
      return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(),
          body: const EmptyState('Alert not found'),
        ),
      );
    }
    final color = alertTypeColor(a.type);
    final params = MockData.telemetryFor(a.assetTypeCode);
    final message =
        '${a.type == AlertType.failure ? 'Sig failure' : 'Sig predictive'} Alert:\n'
        '"${a.sc}", ${DateFormats.alertMessage(a.incidence)}, "${a.assetNumberCode}", "${a.causeCode}"';

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text('${a.sc}  ${a.assetNumberCode}')),
        body: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.causeCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        StatusBadge(
                          text: a.type.code,
                          color: color,
                          filled: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(a.causeDetail),
                    const Divider(height: 24),
                    InfoRow('Zone / Division', '${a.zc} / ${a.dc}'),
                    InfoRow('Station', a.sc),
                    InfoRow(
                      'Asset type',
                      '${MockData.assetTypeName(a.assetTypeCode)} (${a.assetTypeCode})',
                    ),
                    InfoRow('Asset number', a.assetNumberCode),
                    InfoRow('Incidence', DateFormats.dateTime(a.incidence)),
                    InfoRow(
                      'Rectification',
                      a.rectification == null
                          ? '-----'
                          : DateFormats.dateTime(a.rectification!),
                    ),
                    InfoRow(
                      'Incidence duration',
                      DateFormats.duration(a.duration),
                    ),
                    InfoRow('Alert status', a.status.code),
                  ],
                ),
              ),
            ),
            const SectionTitle('Alert message'),
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: SelectableText(
                  message,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
            const SectionTitle('Parameters at the time of alert'),
            Card(
              child: Column(
                children: params
                    .map(
                      (p) => ListTile(
                        dense: true,
                        title: Text(
                          p.code,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(p.name),
                        trailing: Text(
                          '${p.value} ${p.unit}',
                          style: TextStyle(
                            color: statusColor(p.status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SectionTitle('Feedback & remarks'),
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: a.feedback == null && !context.watchRole().canControl
                    // Feedback is a Station-level control function (§11.6).
                    ? const Text(
                        'Feedback pending from the station maintainer.',
                      )
                    : a.feedback == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Feedback pending. Attend the failure / prediction and give feedback.',
                          ),
                          const SizedBox(height: 12),
                          GradientButton(
                            label: 'Give feedback',
                            onPressed: () async {
                              if (await showFeedbackSheet(context, a)) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          InfoRow(
                            'Feedback',
                            '${a.feedback!.code} – ${a.feedback!.label}',
                          ),
                          InfoRow(
                            'Feedback time',
                            DateFormats.dateTime(a.feedbackTime!),
                          ),
                          InfoRow(
                            'Maintainer',
                            '${a.maintainerName} (${a.maintainerDesignation})',
                          ),
                          InfoRow('Mobile', a.maintainerMobile ?? '-'),
                          InfoRow('Remarks', a.remarks ?? '-'),
                        ],
                      ),
              ),
            ),
            const SectionTitle('Escalation'),
            const Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Text(
                  'Maintainer: immediately · JE/SE: after 30 min · SSE: after 1 h · ASTE/DSTE: after 2 h '
                  '(if feedback is still pending). Repeat alerts are not counted in totals.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
