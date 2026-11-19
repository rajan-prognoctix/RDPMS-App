import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Admin (Annex E §13): configurable parameters (Annex D §17), users, audit log (Annex D §19).
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<void> _edit(ConfigParameter p) async {
    final controller = TextEditingController(text: p.value);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.name, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            helperText: 'Use "No time limit" to disable',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          GradientButton(
            label: 'Save',
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) setState(() => p.value = value);
  }

  @override
  Widget build(BuildContext context) {
    const users = [
      ('Demo Maintainer', 'ESM', UserRole.station, 'PRYJ'),
      ('A. Verma', 'JE/Sig', UserRole.station, 'PRYJ'),
      ('R. Mishra', 'SSE/Sig', UserRole.division, 'PYRJ'),
      ('K. Rao', 'DSTE', UserRole.division, 'PYRJ'),
      ('Guest User', 'Viewer', UserRole.guest, 'PYRJ'),
    ];

    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Configuration'),
                Tab(text: 'Users'),
                Tab(text: 'Audit log'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.separated(
                padding: AppSpacing.screenPadding,
                itemCount: MockData.configParameters.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final p = MockData.configParameters[i];
                  return Card(
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.value,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Icon(Icons.edit, size: 16),
                        ],
                      ),
                      onTap: () => _edit(p),
                    ),
                  );
                },
              ),
              ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  ...users.map((u) {
                    final (name, desig, role, juris) = u;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(name[0])),
                        title: Text(name),
                        subtitle: Text('$desig · ${role.label} level · $juris'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text(
                    'HQ & Division users can assign users. Station users can acknowledge and control but cannot assign users. '
                    'Guest users have limited monitoring only.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              ListView(
                padding: AppSpacing.screenPadding,
                children: MockData.auditLog
                    .map(
                      (e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.gpp_maybe,
                            color: AppColors.failure,
                          ),
                          title: Text(
                            e.detail,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            '${e.source} · ${DateFormats.dateTime(e.time)}',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
