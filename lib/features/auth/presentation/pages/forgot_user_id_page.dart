import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';

enum _Step { mobile, otp, details }

/// Forgot User ID: registered mobile → OTP → user details (User ID, name, role…)
/// → back to Sign in. No design exists on the canvas yet, so this follows the
/// Forgot password page. Uses mock data until the recovery API is available.
class ForgotUserIdPage extends StatefulWidget {
const ForgotUserIdPage({super.key});

  @override
  State<ForgotUserIdPage> createState() => _ForgotUserIdPageState();
}

class _ForgotUserIdPageState extends State<ForgotUserIdPage> {
  static const _otpLength = 6;
  static const _resendSeconds = 30;

  final _mobileKey = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();

  _Step _step = _Step.mobile;
  Timer? _timer;
  int _secondsLeft = 0;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _otpFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mobile.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  /// "98XXXXXX21" style masking of the entered number.
  String get _maskedMobile {
    final m = _mobile.text.trim();
    if (m.length < 4) return m;
    return '${m.substring(0, 2)}${'X' * (m.length - 4)}${m.substring(m.length - 2)}';
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
    if (!_mobileKey.currentState!.validate()) return;
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
    FocusScope.of(context).unfocus();
    setState(() => _step = _Step.details);
  }

  void _goToLogin() => context.go(RouteNames.login);

  void _back() {
    switch (_step) {
      case _Step.mobile:
        if (context.canPop()) {
          context.pop();
        } else {
          _goToLogin();
        }
      case _Step.otp:
        _timer?.cancel();
        setState(() => _step = _Step.mobile);
      case _Step.details:
        _goToLogin();
    }
  }

  // ---------- shared pieces ----------

  OutlineInputBorder _outline(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _decoration({String? hint, Widget? prefixIcon}) => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        hintText: hint,
        hintStyle: AppTextStyles.fieldHint,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIcon: prefixIcon,
        enabledBorder: _outline(AppColors.chipBorder),
        focusedBorder: _outline(AppColors.primary, 1.5),
        errorBorder: _outline(AppColors.failure),
        focusedErrorBorder: _outline(AppColors.failure, 1.5),
      );

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

  // ---------- step 1: mobile ----------

  List<Widget> _mobileStep() => [
        _heading(
          'Forgot User ID?',
          const Text(
            'Enter the mobile number registered with your account. We will send an OTP to verify it.',
          ),
        ),
        Form(
          key: _mobileKey,
          child: LabeledField(
            label: 'Registered mobile number',
            child: TextFormField(
              controller: _mobile,
              autofocus: true,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 16, color: AppColors.textMain),
              decoration: _decoration(
                hint: 'Enter 10-digit mobile number',
                prefixIcon: const Icon(Icons.phone_android_outlined, size: 20, color: AppColors.primary),
              ),
              validator: Validators.mobile,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _sendOtp(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mobile number changed? Contact your administrator.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const Spacer(),
        const SizedBox(height: 20),
        GradientButton(label: 'Send OTP', onPressed: _sendOtp),
      ];

  // ---------- step 2: OTP ----------

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
          Text.rich(
            TextSpan(
              text: 'Sent by SMS to ',
              children: [
                TextSpan(
                  text: _maskedMobile,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMain),
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
        GradientButton(
          label: 'Verify OTP',
          onPressed: _otp.text.length == _otpLength ? _verifyOtp : null,
        ),
      ];

  // ---------- step 3: user details ----------

  Widget _detailRow(String label, String value, {bool emphasise = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: emphasise ? 16 : 14,
                  fontWeight: emphasise ? FontWeight.w700 : FontWeight.w500,
                  color: emphasise ? AppColors.navy : AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      );

  List<Widget> _detailsStep() => [
        _heading(
          'Your account details',
          const Text('Use this User ID to sign in.'),
        ),
        AppCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text('User ID', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  const Spacer(),
                  const SelectableText(
                    MockData.userId,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    color: AppColors.primary,
                    tooltip: 'Copy User ID',
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: MockData.userId));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(content: Text('User ID copied')));
                    },
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.border),
              _detailRow('Name', MockData.userName),
              _detailRow('Designation', MockData.userDesignation),
              _detailRow('Role', MockData.userRole.label),
              _detailRow('Jurisdiction', MockData.userJurisdiction),
              _detailRow('Mobile', _maskedMobile),
              _detailRow('Email', MockData.userEmail),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Forgot your password too?',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            TextButton(
              onPressed: () => context.pushReplacement(RouteNames.forgotPassword),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Reset it'),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Go to Sign in',
          leadingIcon: Icons.login,
          onPressed: _goToLogin,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final children = switch (_step) {
      _Step.mobile => _mobileStep(),
      _Step.otp => _otpStep(),
      _Step.details => _detailsStep(),
    };

    return PopScope(
      canPop: _step == _Step.mobile,
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
          title: const Text('Forgot User ID'),
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
