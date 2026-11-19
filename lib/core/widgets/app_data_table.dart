import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Horizontally scrollable report table. Cells may be `String` or `Widget`.
class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Object>> rows;

  const AppDataTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No records for the selected filters')),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 12),
          dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          columnSpacing: 18,
          horizontalMargin: 12,
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 52,
          columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows: rows
              .map((r) => DataRow(
                    cells: r.map((c) => DataCell(c is Widget ? c : Text('$c'))).toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
