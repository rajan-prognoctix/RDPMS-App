import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../widgets/profile_photo_picker.dart';

/// "Sign in for New User" — access request; approved by HQ/Division admin (§11.6, §11.7).
class RegisterPage extends StatefulWidget {
  /// Defaults to the registered [PhotoPickerService]; pass one in tests.
  final PhotoPickerService? photoPicker;

  const RegisterPage({super.key, this.photoPicker});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final PhotoPickerService _photoPicker = widget.photoPicker ?? sl<PhotoPickerService>();
  UserRole _role = UserRole.station;
  String? _station;
  String? _photoPath;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request submitted. You will get an SMS once the admin approves it.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final stations = [
      for (final z in MockData.zones)
        for (final d in z.divisions)
          for (final s in d.stations) '${z.zc} / ${d.dc} / ${s.sc}',
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _goToLogin,
        ),
        title: const Text('New user registration'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // SingleChildScrollView (not ListView) so every field is built and
            // validated even when it's scrolled off screen.
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _formFields(stations),
                ),
              ),
            ),
            _BottomBar(onSubmit: _submit, onSignIn: _goToLogin),
          ],
        ),
      ),
    );
  }

  void _goToLogin() => context.canPop() ? context.pop() : context.go(RouteNames.login);

  List<Widget> _formFields(List<String> stations) => [
            ProfilePhotoPicker(
              photoPath: _photoPath,
              picker: _photoPicker,
              onChanged: (path) => setState(() => _photoPath = path),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => Validators.required(v, 'Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mobile number (registered)'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit mobile number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email id'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Designation (ESM / JE / SSE / ASTE / DSTE)'),
              validator: (v) => Validators.required(v, 'Designation'),
            ),
            const SizedBox(height: 16),
            const Text('User level', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: UserRole.selfSignUp
                  .map((r) => ChoiceChip(
                        label: Text(r.label),
                        selected: _role == r,
                        onSelected: (_) => setState(() => _role = r),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _station,
              decoration: const InputDecoration(labelText: 'Jurisdiction (Zone / Division / Station)'),
              items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _station = v),
              validator: (v) => v == null ? 'Select jurisdiction' : null,
            ),
      ];
}

/// Fixed bottom area: Submit request + "Already have an account? Sign in".
class _BottomBar extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onSignIn;

  const _BottomBar({required this.onSubmit, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.screen,
            AppSpacing.screen,
            4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientButton(
                label: 'Submit request',
                icon: Icons.arrow_forward,
                onPressed: onSubmit,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: onSignIn,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
