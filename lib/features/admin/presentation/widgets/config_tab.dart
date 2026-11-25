import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/entities/config_setting.dart';

/// Long names for the value columns of a [ConfigSetting].
const _keyNames = {
  'PM': 'Point machine',
  'LC': 'LC gate',
  'TC/AC': 'Track circuit / Axle counter',
};

String _keyName(String key) => _keyNames[key] ?? key;

/// Configuration tab (Annex D §17; web design W22): every configurable
/// parameter with its values. Editable when [canEdit]; each save is logged.
class ConfigTab extends StatelessWidget {
  final List<ConfigSetting> settings;
  final bool canEdit;
  final Future<String?> Function(ConfigSetting) onSave;

  const ConfigTab({
    super.key,
    required this.settings,
    required this.canEdit,
    required this.onSave,
  });

  Future<void> _edit(BuildContext context, ConfigSetting setting) async {
    final updated = await showModalBottomSheet<ConfigSetting>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ConfigEditor(setting: setting),
    );
    if (updated == null || !context.mounted) return;
    final error = await onSave(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Parameter #${setting.number} saved and logged',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (settings.isEmpty) {
      return const EmptyState('No parameters', icon: Icons.tune);
    }
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          canEdit
              ? 'Annex D §17 — set as decided by the Zonal Railway. "No time limit" is allowed. '
                    'Every change is written to the audit log.'
              : 'View only. Users with Admin access can change these parameters.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        for (final s in settings)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            onTap: canEdit ? () => _edit(context, s) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${s.number}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (canEdit)
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.scope} · ${s.unit} · ${s.source}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final k in s.keys)
                      _ValueChip(
                        label: s.keys.length == 1 ? null : k,
                        value: s.valueOf(k),
                        unit: s.unit,
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String? label;
  final ConfigValue value;
  final String unit;

  const _ValueChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final fg = value.isSet ? AppColors.textMain : AppColors.predictiveText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value.isSet ? AppColors.neutralSoft : AppColors.predictiveSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (label != null)
              TextSpan(
                text: '$label  ',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            TextSpan(
              text: value.display(unit),
              style: TextStyle(fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// Bottom-sheet editor: one number per column, or "No time limit". Empty and
/// unchecked = "Not set". Pops the updated setting, or null on cancel.
class _ConfigEditor extends StatefulWidget {
  final ConfigSetting setting;
  const _ConfigEditor({required this.setting});

  @override
  State<_ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends State<_ConfigEditor> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, bool> _noLimit;

  @override
  void initState() {
    super.initState();
    final s = widget.setting;
    _controllers = {
      for (final k in s.keys)
        k: TextEditingController(text: _format(s.valueOf(k).amount)),
    };
    _noLimit = {for (final k in s.keys) k: s.valueOf(k).noTimeLimit};
  }

  static String _format(double? a) {
    if (a == null) return '';
    return a == a.roundToDouble() ? a.toInt().toString() : a.toString();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final s = widget.setting;
    final values = <String, ConfigValue>{
      for (final k in s.keys)
        k: _noLimit[k]!
            ? const ConfigValue.noTimeLimit()
            : (_controllers[k]!.text.trim().isEmpty
                  ? const ConfigValue.notSet()
                  : ConfigValue(double.parse(_controllers[k]!.text.trim()))),
    };
    Navigator.pop(context, s.copyWith(values: values));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.setting;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '#${s.number}  ${s.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.scope} · in ${s.unit} · default from ${s.source}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                for (final k in s.keys) ...[
                  Text(_keyName(k), style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controllers[k],
                          enabled: !_noLimit[k]!,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: _noLimit[k]!
                                ? 'No time limit'
                                : 'Not set',
                            suffixText: s.unit,
                          ),
                          validator: (v) {
                            if (_noLimit[k]! || v == null || v.trim().isEmpty) {
                              return null;
                            }
                            final n = double.tryParse(v.trim());
                            return n == null || n <= 0
                                ? 'Enter a number above 0'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('No time limit'),
                        selected: _noLimit[k]!,
                        onSelected: (v) => setState(() => _noLimit[k] = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(label: 'Save', onPressed: _save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
