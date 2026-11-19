import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/rdpms_app_bar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../widgets/asset_group_card.dart';

/// Dashboard (Annex E §6, Annex G): live asset status, sensor/IoT health, server utilisation.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = MockData.dashboardGroups;
    final healthy = groups.fold(0, (s, g) => s + g.healthy);
    final predictive = groups.fold(0, (s, g) => s + g.predictive);
    final failure = groups.fold(0, (s, g) => s + g.failure);
    final pending = MockData.alerts.where((a) => a.status == AlertStatus.pending).take(3).toList();

    return Scaffold(
      appBar: const RdpmsAppBar(title: 'Dashboard'),
      body: ListView(
        children: [
          FilterBar(onSearch: (_) {}),
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TotalCard(healthy: healthy, predictive: predictive, failure: failure),
                const SectionTitle('Signalling assets'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45,
                  children: groups.map((g) => AssetGroupCard(group: g)).toList(),
                ),
                const SectionTitle('RDPMS health'),
                Row(
                  children: [
                    Expanded(
                      child: _HealthCard(
                        title: 'Sensors',
                        healthy: MockData.sensorsHealthy,
                        failed: MockData.sensorsFailed,
                        // Switch to the Health tab (bottom bar index 3).
                        onTap: () => context.go(RouteNames.health),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HealthCard(
                        title: 'IoT',
                        healthy: MockData.iotHealthy,
                        failed: MockData.iotFailed,
                        onTap: () => context.go(RouteNames.health),
                      ),
                    ),
                  ],
                ),
                const SectionTitle('RDPMS application server'),
                const _ServerUsageCard(),
                SectionTitle(
                  'Latest pending alerts',
                  trailing: TextButton(
                    // Switch to the Alerts tab (bottom bar index 1).
                    onPressed: () => context.go(RouteNames.alerts),
                    child: const Text('View all'),
                  ),
                ),
                ...pending.map((a) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.warning_rounded, color: alertTypeColor(a.type)),
                        title: Text('${a.sc}  ${a.assetNumberCode}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(a.causeCode),
                        trailing: StatusBadge(text: a.type.code, color: alertTypeColor(a.type)),
                        onTap: () => context.push(RouteNames.alertDetail(a.id)),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int healthy, predictive, failure;
  const _TotalCard({required this.healthy, required this.predictive, required this.failure});

  @override
  Widget build(BuildContext context) {
    final total = healthy + predictive + failure;
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total assets: $total', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  Expanded(flex: healthy, child: Container(height: 10, color: AppColors.healthy)),
                  Expanded(flex: predictive, child: Container(height: 10, color: AppColors.predictive)),
                  Expanded(flex: failure, child: Container(height: 10, color: AppColors.failure)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CounterChip(label: 'Healthy', count: healthy, color: AppColors.healthy),
                const SizedBox(width: 8),
                CounterChip(label: 'Predictive', count: predictive, color: AppColors.predictive),
                const SizedBox(width: 8),
                CounterChip(label: 'Failure', count: failure, color: AppColors.failure),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final int healthy, failed;
  final VoidCallback onTap;
  const _HealthCard({required this.title, required this.healthy, required this.failed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Healthy - $healthy', style: const TextStyle(color: AppColors.healthy)),
              Text('Failed - $failed', style: const TextStyle(color: AppColors.failure)),
            ],
          ),
        ),
      ),
    );
  }
}

/// % utilisation of CPU, RAM & storage; must stay ≤ 70 % (§11.4).
class _ServerUsageCard extends StatelessWidget {
  const _ServerUsageCard();

  @override
  Widget build(BuildContext context) {
    Widget bar(String label, double v) {
      final color = v > 0.7 ? AppColors.failure : AppColors.healthy;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 64, child: Text(label)),
            Expanded(
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: color,
                backgroundColor: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 48, child: Text('${(v * 100).round()}%', textAlign: TextAlign.end)),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            bar('CPU', MockData.cpuUsage),
            bar('RAM', MockData.ramUsage),
            bar('Storage', MockData.storageUsage),
            const SizedBox(height: 4),
            const Text('Limit: 70% of available hardware',
                style: TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
