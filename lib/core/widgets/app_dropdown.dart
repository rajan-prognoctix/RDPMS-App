import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compact filter dropdown used in every page header (Annex E §5).
/// `null` value = "ALL".
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool allowAll;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.allowAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final current = items.contains(value) ? value : null;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: current,
          isDense: true,
          hint: Text(label, style: const TextStyle(fontSize: 13)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [
            if (allowAll)
              DropdownMenuItem<T?>(value: null, child: Text('All $label')),
            ...items.map((e) => DropdownMenuItem<T?>(value: e, child: Text(itemLabel(e)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Segmented toggle for the "View" icon (Table / Graph / Pictorial …).
class ViewToggle extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const ViewToggle({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: options.map((o) => ButtonSegment(value: o, label: Text(o))).toList(),
      selected: {selected},
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
