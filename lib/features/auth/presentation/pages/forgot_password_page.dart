import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';

enum _Step { userId, otp, newPassword }

/// Forgot password: User ID → OTP to the registered mobile → new password.
/// No design exists on the canvas yet, so this follows the M01/M02 style.
/// Uses mock data until the reset-password API is available.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _otpLength = 6;
  static const _resendSeconds = 30;

  final _userIdKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  _Step _step = _Step.userId;
  Timer? _timer;
  int _secondsLeft = 0;
  String? _otpError;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _otpFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userId.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _sendOtp() {
    if (!_userIdKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _step = _Step.otp;
      _otp.clear();
      _otpError = null;
    });
    _startTimer();
  }

  void _verifyOtp() {
    if (_otp.text != MockData.demoOtp) {
      setState(() => _otpError = 'Invalid OTP');
      return;
    }
    _timer?.cancel();
    setState(() => _step = _Step.newPassword);
  }

  void _resetPassword() {
    if (!_passwordKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Password reset. Sign in with your new password.')),
      );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.login);
    }
  }

  void _back() {
    switch (_step) {
      case _Step.userId:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.login);
        }
      case _Step.otp:
        _timer?.cancel();
        setState(() => _step = _Step.userId);
      case _Step.newPassword:
        setState(() => _step = _Step.otp);
        _startTimer();
    }
  }

  // ---------- shared pieces ----------

  OutlineInputBorder _outline(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _decoration({Widget? suffixIcon}) => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffixIcon,
        enabledBorder: _outline(AppColors.chipBorder),
        focusedBorder: _outline(AppColors.primary, 1.5),
        errorBorder: _outline(AppColors.failure),
        focusedErrorBorder: _outline(AppColors.failure, 1.5),
      );

  Widget _field(String label, Widget input) => LabeledField(label: label, child: input);

  Widget _primaryButton(String label, VoidCallback? onPressed) =>
      GradientButton(label: label, onPressed: onPressed);

  Widget _heading(String title, Widget subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textMuted),
            child: subtitle,
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget _stepIndicator() {
    final current = _step.index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: List.generate(_Step.values.length, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < _Step.values.length - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.track,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------- steps ----------

  List<Widget> _userIdStep() => [
        _heading(
          'Forgot password?',
          const Text(
            'Enter your User ID. We will send an OTP to the mobile number registered with your account.',
          ),
        ),
        Form(
          key: _userIdKey,
          child: _field(
            'User ID',
            TextFormField(
              controller: _userId,
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: AppColors.textMain),
              decoration: _decoration(),
              validator: (v) => Validators.required(v, 'User id'),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _sendOtp(),
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 20),
        _primaryButton('Send OTP', _sendOtp),
      ];

  Widget _digitBox(int index) {
    final value = _otp.text;
    final isActive = _otpFocus.hasFocus &&
        (index == value.length || (value.length == _otpLength && index == _otpLength - 1));
    final Color borderColor;
    final double borderWidth;
    if (_otpError != null) {
      borderColor = AppColors.failure;
      borderWidth = 1;
    } else if (isActive) {
      borderColor = AppColors.primary;
      borderWidth = 2;
    } else {
      borderColor = AppColors.chipBorder;
      borderWidth = 1;
    }
    return Container(
      width: 46,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Text(
        index < value.length ? value[index] : '',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.navy,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  String get _countdown =>
      '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';

  List<Widget> _otpStep() => [
        _heading(
          'Enter the OTP',
          const Text.rich(
            TextSpan(
              text: 'Sent by SMS to your registered mobile ',
              children: [
                TextSpan(
                  text: MockData.userMobile,
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMain),
                ),
              ],
            ),
          ),
        ),
        Semantics(
          label: 'One-time password',
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, _digitBox),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _otp,
                    focusNode: _otpFocus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: _otpLength,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    expands: true,
                    maxLines: null,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                    onChanged: (_) => setState(() => _otpError = null),
                    onSubmitted: (_) => _verifyOtp(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 8),
          Text(_otpError!, style: const TextStyle(fontSize: 13, color: AppColors.failure)),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            if (_secondsLeft > 0)
              Text(
                'Resend OTP in $_countdown',
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              )
            else
              TextButton(
                onPressed: _startTimer,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                child: const Text('Resend OTP'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Demo OTP: ${MockData.demoOtp}',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const Spacer(),
        const SizedBox(height: 20),
        _primaryButton('Verify OTP', _otp.text.length == _otpLength ? _verifyOtp : null),
      ];

  List<Widget> _newPasswordStep() => [
        _heading(
          'Set a new password',
          const Text('Choose a password with at least 6 characters.'),
        ),
        Form(
          key: _passwordKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                'New password',
                TextFormField(
                  controller: _newPassword,
                  autofocus: true,
                  obscureText: _obscureNew,
                  style: const TextStyle(fontSize: 16, color: AppColors.textMain),
                  decoration: _decoration(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                      color: AppColors.textLabel,
                      tooltip: _obscureNew ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 18),
              _field(
                'Confirm new password',
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(fontSize: 16, color: AppColors.textMain),
                  decoration: _decoration(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      color: AppColors.textLabel,
                      tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm the password';
                    if (v != _newPassword.text) return 'Passwords do not match';
                    return null;
                  },
                  onFieldSubmitted: (_) => _resetPassword(),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(height: 20),
        _primaryButton('Reset password', _resetPassword),
      ];

  @override
  Widget build(BuildContext context) {
    final children = switch (_step) {
      _Step.userId => _userIdStep(),
      _Step.otp => _otpStep(),
      _Step.newPassword => _newPasswordStep(),
    };

    return PopScope(
      canPop: _step == _Step.userId,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceMuted,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _back,
          ),
          title: const Text('Reset password'),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_stepIndicator(), ...children],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
