import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../bloc/auth_bloc.dart';

/// User ID + password form. Sign-in is always OTP based (§11.7).
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userId.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          LoginRequested(userId: _userId.text.trim(), password: _password.text),
        );
  }

  OutlineInputBorder _outline(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _decoration({required String hint, required IconData icon, Widget? suffixIcon}) =>
      InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        isDense: true,
        hintText: hint,
        hintStyle: AppTextStyles.fieldHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        suffixIcon: suffixIcon,
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.primary, 1.5),
        errorBorder: _outline(AppColors.failure),
        focusedErrorBorder: _outline(AppColors.failure, 1.5),
      );

  Widget _field(String label, Widget input) => LabeledField(label: label, child: input);

  Widget _linkButton(String label, String route) => TextButton(
        onPressed: () => context.push(route),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      );

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthBloc b) => b.state is AuthLoading);
    const inputStyle = TextStyle(fontSize: 16, color: AppColors.textMain);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            'User ID',
            TextFormField(
              controller: _userId,
              style: inputStyle,
              decoration: _decoration(hint: 'Enter your User ID', icon: Icons.person_outline),
              validator: (v) => Validators.required(v, 'User id'),
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 25),
          _field(
            'Password',
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              style: inputStyle,
              decoration: _decoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  color: AppColors.textMuted,
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: Validators.password,
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _linkButton('Forgot User ID?', RouteNames.forgotUserId),
              _linkButton('Forgot password?', RouteNames.forgotPassword),
            ],
          ),
          const SizedBox(height: 25),
          GradientButton(
            label: 'Sign in',
            icon: Icons.arrow_forward,
            loading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
