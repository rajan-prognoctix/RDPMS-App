import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Alert feedback (Annex D §6–7): T / PT / F / M + remarks + rectification date & time.
/// PT shows a dropdown of all causes for the asset type. Returns true when submitted.
Future<bool> showFeedbackSheet(BuildContext context, RdpmsAlert alert, {AlertFeedback? initial}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FeedbackSheet(alert: alert, initial: initial),
  );
  return result ?? false;
}

class _FeedbackSheet extends StatefulWidget {
  final RdpmsAlert alert;
  final AlertFeedback? initial;
  const _FeedbackSheet({required this.alert, this.initial});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  late AlertFeedback? _feedback = widget.initial;
  String? _actualCause;
  DateTime _rectification = DateTime.now();
  final _remarks = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _pickRectification() async {
    final date = await showDatePicker(
      context: context,
      firstDate: widget.alert.incidence,
      lastDate: DateTime.now(),
      initialDate: _rectification,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_rectification));
    if (time == null) return;
    setState(() => _rectification = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    if (_feedback == null) return setState(() => _error = 'Select feedback T / PT / F / M');
    if (_feedback == AlertFeedback.pt && _actualCause == null) {
      return setState(() => _error = 'Select the actual cause found at site');
    }
    if (_remarks.text.trim().isEmpty) return setState(() => _error = 'Remarks are required');

    final a = widget.alert
      ..feedback = _feedback
      ..feedbackTime = DateTime.now()
      ..rectification = _rectification
      ..remarks = [if (_actualCause != null) 'Actual cause: $_actualCause.', _remarks.text.trim()].join(' ')
      ..maintainerName = MockData.userName
      ..maintainerDesignation = MockData.userDesignation
      ..maintainerMobile = MockData.userMobile
      ..status = AlertStatus.cleared;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback "${a.feedback!.code}" submitted for ${a.assetNumberCode}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final causes = MockData.causesByAssetType[widget.alert.assetTypeCode] ?? [widget.alert.causeCode];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.screen,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Feedback – ${widget.alert.sc} ${widget.alert.assetNumberCode}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${widget.alert.type.code} · ${widget.alert.causeCode}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            SegmentedButton<AlertFeedback>(
              segments: AlertFeedback.values
                  .map((f) => ButtonSegment(value: f, label: Text(f.code), tooltip: f.label))
                  .toList(),
              selected: {?_feedback},
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                _feedback = s.isEmpty ? null : s.first;
                _error = null;
              }),
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_feedback!.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              ),
            if (_feedback == AlertFeedback.pt) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _actualCause,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Actual cause found at site'),
                items: causes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _actualCause = v),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickRectification,
              icon: const Icon(Icons.event_available),
              label: Text('Rectification: ${DateFormats.dateTime(_rectification)}'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _remarks,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Remarks', alignLabelWithHint: true),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 8),
            const Text(
              'Feedback cannot be changed by the maintainer after submission. JE/SSE can modify it with remarks.',
              style: TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const SizedBox(height: 12),
            GradientButton(label: 'Submit feedback', onPressed: _submit),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
