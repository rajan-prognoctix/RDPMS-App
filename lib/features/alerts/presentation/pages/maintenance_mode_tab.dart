import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Maintenance mode (Annex D §5, Annex E §7.4): stop alerts during maintenance.
class MaintenanceModeTab extends StatefulWidget {
  const MaintenanceModeTab({super.key});

  @override
  State<MaintenanceModeTab> createState() => _MaintenanceModeTabState();
}

class _MaintenanceModeTabState extends State<MaintenanceModeTab> {
  String? _station;
  Asset? _asset;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now().add(const Duration(hours: 1));

  List<String> get _stations => MockData.assets.map((a) => a.sc).toSet().toList();

  Future<DateTime?> _pick(DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (d == null || !mounted) return null;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  void _activate() {
    if (_asset == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select station and asset')));
      return;
    }
    if (!_to.isAfter(_from)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('"To" must be after "From"')));
      return;
    }
    setState(() {
      // Re-activating the same asset modifies its period (Annex D §5.3).
      MockData.maintenanceModes.removeWhere((m) => m.assetNumberCode == _asset!.assetNumberCode && m.sc == _asset!.sc);
      MockData.maintenanceModes.add(MaintenanceMode(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sc: _asset!.sc,
        assetTypeCode: _asset!.assetTypeCode,
        assetNumberCode: _asset!.assetNumberCode,
        from: _from,
        to: _to,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Maintenance mode active for ${_asset!.assetNumberCode}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assets = MockData.assets.where((a) => a.sc == _station).toList();
    final active = MockData.maintenanceModes.where((m) => m.to.isAfter(DateTime.now())).toList();

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Card(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Activate maintenance mode', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _station,
                  decoration: const InputDecoration(labelText: 'Station'),
                  items: _stations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() {
                    _station = v;
                    _asset = null;
                  }),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Asset>(
                  key: ValueKey(_station),
                  initialValue: _asset,
                  decoration: const InputDecoration(labelText: 'Asset (type · number)'),
                  items: assets
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text('${MockData.assetTypeName(a.assetTypeCode)} · ${a.assetNumberCode}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _asset = v),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final d = await _pick(_from);
                          if (d != null) setState(() => _from = d);
                        },
                        child: Text('From\n${DateFormats.date(_from)} ${DateFormats.time(_from)}',
                            textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final d = await _pick(_to);
                          if (d != null) setState(() => _to = d);
                        },
                        child: Text('To\n${DateFormats.date(_to)} ${DateFormats.time(_to)}',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'ACTIVATE',
                  leadingIcon: Icons.power_settings_new,
                  onPressed: _activate,
                ),
              ],
            ),
          ),
        ),
        SectionTitle('Active maintenance modes (${active.length})', trailing: const DownloadButton()),
        if (active.isEmpty) const EmptyState('No asset is in maintenance mode', icon: Icons.build_outlined),
        ...active.map((m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.build_circle, color: AppColors.predictive),
                title: Text('${m.sc} · ${MockData.assetTypeName(m.assetTypeCode)} · ${m.assetNumberCode}'),
                subtitle: Text(
                    '${DateFormats.date(m.from)} ${DateFormats.time(m.from)}  →  ${DateFormats.date(m.to)} ${DateFormats.time(m.to)}'),
                trailing: OutlinedButton(
                  onPressed: () => setState(() => MockData.maintenanceModes.remove(m)),
                  child: const Text('Clear'),
                ),
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Clears automatically at end time. If left active, a reminder alert is sent every '
          '${MockData.maintenanceReminder['EOP']} (point machine), ${MockData.maintenanceReminder['DCT']} '
          '(track circuit), ${MockData.maintenanceReminder['LED']} (signal).',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
