import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../widgets/alert_card.dart';
import '../widgets/feedback_sheet.dart';

/// Alert Live (Annex E §7.1): only "pending" alerts.
class AlertLiveTab extends StatefulWidget {
  const AlertLiveTab({super.key});

  @override
  State<AlertLiveTab> createState() => _AlertLiveTabState();
}

class _AlertLiveTabState extends State<AlertLiveTab> {
  LocationFilter _location = const LocationFilter();
  AlertType? _alertType;
  String? _assetType;
  // Values applied on search
  AlertType? _appliedType;
  String? _appliedAssetType;

  List<RdpmsAlert> get _alerts => MockData.alerts
      .where((a) => a.status == AlertStatus.pending)
      .where((a) => _location.matches(zc: a.zc, dc: a.dc, sc: a.sc))
      .where((a) => _appliedType == null || a.type == _appliedType)
      .where((a) => _appliedAssetType == null || a.assetTypeCode == _appliedAssetType)
      .toList()
    ..sort((a, b) => b.incidence.compareTo(a.incidence));

  Future<void> _feedback(RdpmsAlert alert, AlertFeedback? f) async {
    final done = await showFeedbackSheet(context, alert, initial: f);
    if (done) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _alerts;
    final failure = alerts.where((a) => a.type == AlertType.failure).length;
    final predictive = alerts.length - failure;
    final normal = MockData.dashboardGroups.fold(0, (s, g) => s + g.healthy);

    return ListView(
      children: [
        FilterBar(
          extraFilters: [
            AppDropdown<AlertType>(
              label: 'Alert Type',
              value: _alertType,
              items: AlertType.values,
              itemLabel: (t) => t.code,
              onChanged: (v) => setState(() => _alertType = v),
            ),
            AppDropdown<String>(
              label: 'Asset Type',
              value: _assetType,
              items: MockData.assetTypeNames.keys.toList(),
              itemLabel: MockData.assetTypeName,
              onChanged: (v) => setState(() => _assetType = v),
            ),
          ],
          onSearch: (loc) => setState(() {
            _location = loc;
            _appliedType = _alertType;
            _appliedAssetType = _assetType;
          }),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CounterChip(label: 'Normal', count: normal, color: AppColors.healthy),
                  const SizedBox(width: 8),
                  CounterChip(label: 'Predictive', count: predictive, color: AppColors.predictive),
                  const SizedBox(width: 8),
                  CounterChip(label: 'Failure', count: failure, color: AppColors.failure),
                ],
              ),
              const SizedBox(height: 12),
              if (alerts.isEmpty) const EmptyState('No pending alerts', icon: Icons.check_circle_outline),
              ...alerts.map((a) => AlertCard(
                    alert: a,
                    onTap: () => context.push(RouteNames.alertDetail(a.id)).then((_) => setState(() {})),
                    onAck: () {
                      setState(() => a.acknowledged = true);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('${a.assetNumberCode} alert acknowledged')));
                    },
                    onFeedback: (f) => _feedback(a, f),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
