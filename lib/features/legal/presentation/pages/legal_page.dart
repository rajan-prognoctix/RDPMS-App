import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum LegalDocument { privacyPolicy, terms }

/// Privacy Policy / Terms & Conditions, opened from the login page.
/// PLACEHOLDER: section headings only; the real text is still to be provided.
class LegalPage extends StatelessWidget {
  final LegalDocument document;

  const LegalPage({super.key, required this.document});

  static const _privacySections = [
    'Information we collect',
    'How we use your information',
    'Device and mobile number binding',
    'Data storage and security',
    'Data sharing',
    'Your rights',
    'Contact us',
  ];

  static const _termsSections = [
    'Acceptance of terms',
    'Authorised use',
    'Account and device responsibilities',
    'Acceptable use',
    'Limitation of liability',
    'Changes to these terms',
    'Contact us',
  ];

  String get _title => switch (document) {
        LegalDocument.privacyPolicy => 'Privacy Policy',
        LegalDocument.terms => 'Terms & Conditions',
      };

  List<String> get _sections => switch (document) {
        LegalDocument.privacyPolicy => _privacySections,
        LegalDocument.terms => _termsSections,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.login),
        ),
        title: Text(_title),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Placeholder. The final text is to be provided.',
                      style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Last updated: —',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  for (final (i, heading) in _sections.indexed) ...[
                    const SizedBox(height: 18),
                    Text(
                      '${i + 1}. $heading',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Content to be provided.',
                      style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
