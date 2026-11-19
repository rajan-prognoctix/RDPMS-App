import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  final LocalStorage? tokenStorage;

  const OtpPage({super.key, this.tokenStorage});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _navy = Color(0xFF13294B);
  static const _primary = Color(0xFF1F5FBF);
  static const _bodyBg = Color(0xFFF3F5F8);
  static const _text = Color(0xFF1A2233);
  static const _muted = Color(0xFF5A6577);
  static const _border = Color(0xFFC5CCD8);
  static const _cardBorder = Color(0xFFD9DEE6);
  static const _errorColor = Color(0xFFC62828);
  static const _otpLength = 6;

  late final LocalStorage _tokens = widget.tokenStorage ?? sl<LocalStorage>();
  final _otp = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = 30;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Correct OTP → save the access token from the password step, then open
  /// Dashboard. Next app start goes straight to Dashboard from Splash (§11.7).
  Future<void> _verify() async {
    if (_otp.text != MockData.demoOtp) {
      setState(() => _error = 'Invalid OTP');
      return;
    }
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) {
      // Password step not done in this run (shouldn't happen): sign in again.
      context.go(RouteNames.login);
      return;
    }
   // await _tokens.saveToken(auth.user.token);
    await _tokens.saveLastSignIn(DateTime.now());
    if (mounted) context.go(RouteNames.dashboard);
  }

  void _backToLogin() => context.go(RouteNames.login);

  String get _countdown =>
      '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';

  Widget _digitBox(int index) {
    final value = _otp.text;
    final isActive = _focus.hasFocus &&
        (index == value.length || (value.length == _otpLength && index == _otpLength - 1));
    final Color borderColor;
    final double borderWidth;
    if (_error != null) {
      borderColor = _errorColor;
      borderWidth = 1;
    } else if (isActive) {
      borderColor = _primary;
      borderWidth = 2;
    } else {
      borderColor = _border;
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
          color: _navy,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canVerify = _otp.text.length == _otpLength;

    // OTP is opened with go(), so there's nothing behind it: Android Back
    // (like the app-bar arrow) returns to Login instead of closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin();
      },
      child: Scaffold(
      backgroundColor: _bodyBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _backToLogin,
        ),
        title: const Text('Verify this phone'),
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
                  children: [
                    const Text(
                      'Enter the OTP',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _navy),
                    ),
                    const SizedBox(height: 6),
                    const Text.rich(
                      TextSpan(
                        text: 'Sent by SMS to your authorised mobile ',
                        children: [
                          TextSpan(
                            text: MockData.userMobile,
                            style: TextStyle(fontWeight: FontWeight.w700, color: _text),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 15, height: 1.5, color: _muted),
                    ),
                    const SizedBox(height: 20),

                    // OTP boxes: one hidden field drives six display boxes.
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
                                focusNode: _focus,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                maxLength: _otpLength,
                                showCursor: false,
                                enableInteractiveSelection: false,
                                expands: true,
                                maxLines: null,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() => _error = null),
                                onSubmitted: (_) => _verify(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(fontSize: 13, color: _errorColor)),
                    ],
                    const SizedBox(height: 12),

                    // Resend
                    Row(
                      children: [
                        if (_secondsLeft > 0)
                          Text(
                            'Resend OTP in $_countdown',
                            style: const TextStyle(fontSize: 14, color: _muted),
                          )
                        else
                          TextButton(
                            onPressed: _startTimer,
                            style: TextButton.styleFrom(
                              foregroundColor: _primary,
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
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 20),

                    // Device card
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.smartphone_outlined, size: 28, color: _primary),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This phone will be linked to your account',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: _text,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Device ID: ${MockData.deviceId}',
                                  style: TextStyle(fontSize: 14, height: 1.5, color: _muted),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'After this one-time step, the app signs you in automatically on this phone.',
                                  style: TextStyle(fontSize: 14, height: 1.5, color: _muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),

                    // Verify
                    GradientButton(
                      label: 'Verify and link phone',
                      onPressed: canVerify ? _verify : null,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Signing in on another phone needs the Admin to reset this link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, height: 1.5, color: _muted),
                    ),
                  ],
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
