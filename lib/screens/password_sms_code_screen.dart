import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_colors.dart';
import '../widgets/app_brand_logo.dart';

class PasswordSmsCodeScreen extends StatefulWidget {
  /// Optional phone number passed from forgot-password screen
  final String? phoneNumber;

  const PasswordSmsCodeScreen({super.key, this.phoneNumber});

  @override
  State<PasswordSmsCodeScreen> createState() => _PasswordSmsCodeScreenState();
}

class _PasswordSmsCodeScreenState extends State<PasswordSmsCodeScreen> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 48;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _resendSeconds;
  Timer? _timer;
  bool _loading = false;

  String get _displayPhone {
    final raw = widget.phoneNumber ?? '+639171234567';
    // Pretty format: +63 917 123 4567
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 12 && digits.startsWith('63')) {
      return '+63 ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }
    if (digits.length >= 10) {
      return '+63 ${digits.substring(digits.length - 10, digits.length - 7)} '
          '${digits.substring(digits.length - 7, digits.length - 4)} '
          '${digits.substring(digits.length - 4)}';
    }
    return raw;
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isComplete => _code.length == _codeLength;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first empty box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste support: distribute digits
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _codeLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length).clamp(0, _codeLength - 1);
      _focusNodes[next].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    // TODO: call resend SMS API
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code resent.')));
    _startTimer();
  }

  Future<void> _verify() async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }

    setState(() => _loading = true);
    // TODO: verify OTP with backend
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    // Success → reset password screen
    Navigator.of(context).pushNamed('/reset-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -90,
            left: -70,
            child: _blob(200, const Color(0xFF96F7B0).withValues(alpha: 0.25)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            right: -80,
            child: _blob(220, const Color(0xFF94F4AD).withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: -50,
            left: MediaQuery.of(context).size.width * 0.2,
            child: _blob(180, const Color(0xFFAEF3B9).withValues(alpha: 0.2)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleBtn(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: context.appBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 14,
                              color: context.appAccent,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'SMS VERIFICATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.7,
                                color: context.appAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleBtn(icon: Icons.help_outline, onTap: () {}),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.appSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.appBorder),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF12562B,
                                ).withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const AppBrandLogo(size: 56),
                        ),
                        const SizedBox(height: 24),

                        // Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: context.appSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.appBorder),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF12562B,
                                ).withValues(alpha: 0.06),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Verify SMS Code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: context.appText,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'We sent a 6-digit verification code to your registered mobile number:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: context.appMutedText,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Phone chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appSurfaceContainer,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: context.appBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.smartphone,
                                      size: 16,
                                      color: context.appAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _displayPhone,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.appText,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: context.appAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // OTP boxes
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(_codeLength, (i) {
                                  final hasValue =
                                      _controllers[i].text.isNotEmpty;
                                  return SizedBox(
                                    width: 48,
                                    height: 56,
                                    child: KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (e) => _onKey(i, e),
                                      child: TextField(
                                        controller: _controllers[i],
                                        focusNode: _focusNodes[i],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: context.appText,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: context.appSurface,
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: context.appBorder,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: hasValue
                                                  ? context.appAccent
                                                        .withValues(alpha: 0.7)
                                                  : context.appBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: context.appAccent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (v) => _onDigitChanged(i, v),
                                        onTap: () {
                                          // Select all on tap for easy replace
                                          _controllers[i].selection =
                                              TextSelection(
                                                baseOffset: 0,
                                                extentOffset:
                                                    _controllers[i].text.length,
                                              );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 20),

                              // Timer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: context.appAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _secondsLeft > 0
                                        ? 'Resend code in '
                                        : 'You can resend the code now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.appMutedText,
                                    ),
                                  ),
                                  if (_secondsLeft > 0)
                                    Text(
                                      _timerText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        letterSpacing: 1,
                                        color: context.appText,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.appMutedText,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Didn't receive the SMS code? ",
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: _secondsLeft == 0
                                            ? _resend
                                            : null,
                                        child: Text(
                                          'Resend Code',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _secondsLeft == 0
                                                ? context.appAccent
                                                : context.appMutedText,
                                            decoration: _secondsLeft == 0
                                                ? TextDecoration.underline
                                                : null,
                                            decorationColor: context.appAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Verify button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _verify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.appAccent,
                                    foregroundColor: context.appOnAccent,
                                    disabledBackgroundColor: context.appAccent
                                        .withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    shadowColor: context.appAccent.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                  child: _loading
                                      ? SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: context.appOnAccent,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Verify & Proceed',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 20),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Divider(
                                color: const Color(
                                  0xFFC0C9BE,
                                ).withValues(alpha: 0.25),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: context.appAccent,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '256-bit AES Encryption • Secure Verification',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.3,
                                      color: context.appMutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Back to login
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/login', (r) => false);
                          },
                          icon: const Icon(Icons.keyboard_backspace, size: 18),
                          label: const Text(
                            'Back to Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.appMutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: context.appMutedText,
                            ),
                            children: [
                              const TextSpan(text: 'Need assistance? '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Contact Deslugify Support',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.appAccent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: context.appAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: context.appSurface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0xFF12562B).withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: context.appText),
        ),
      ),
    );
  }
}
