import 'package:flutter/material.dart';
import 'theme_colors.dart';
import '../widgets/app_brand_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  // ── Password rules ─────────────────────────────────────────────────────
  bool get _hasMinLength => _newPasswordController.text.length >= 8;

  bool get _hasUpperAndNumber {
    final t = _newPasswordController.text;
    return t.contains(RegExp(r'[A-Z]')) && t.contains(RegExp(r'[0-9]'));
  }

  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperAndNumber) score++;
    if (_passwordsMatch) score++;
    return score;
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 3:
        return 'Strong';
      case 2:
        return 'Medium';
      case 1:
        return 'Weak';
      default:
        return 'Too weak';
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 3:
        return context.appAccent;
      case 2:
        return const Color(0xFF7BDA96);
      case 1:
        return const Color(0xFFE6A817);
      default:
        return const Color(0xFFBA1A1A);
    }
  }

  void _submit() {
    if (_strengthScore < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all password requirements.')),
      );
      return;
    }
    // TODO: call API then navigate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successfully!')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -120,
            left: -120,
            child: _blob(220, const Color(0xFF96F7B0).withValues(alpha: 0.3)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -80,
            child: _blob(180, const Color(0xFFAEF3B9).withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: -60,
            left: MediaQuery.of(context).size.width * 0.2,
            child: _blob(180, const Color(0xFF94F4AD).withValues(alpha: 0.25)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────────────────
                  Row(
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF12562B,
                              ).withValues(alpha: 0.04),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppBrandLogo(size: 18),
                            SizedBox(width: 6),
                            Text(
                              'SECURITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: context.appAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleBtn(icon: Icons.help_outline, onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Logo + title ─────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 16),
                  Text(
                    'Create New Password',
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
                    'Your phone number has been verified. Enter and confirm your new secure password below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: context.appMutedText,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Form card ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.appBorder),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF12562B,
                          ).withValues(alpha: 0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // New password
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: context.appMutedText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _passwordField(
                          controller: _newPasswordController,
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        const SizedBox(height: 14),

                        // Strength box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.appSurfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.appBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password Strength',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: context.appMutedText,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _strengthColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _strengthLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _strengthColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Strength bars
                              Row(
                                children: List.generate(3, (i) {
                                  final filled = i < _strengthScore;
                                  return Expanded(
                                    child: Container(
                                      height: 6,
                                      margin: EdgeInsets.only(
                                        right: i < 2 ? 4 : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: filled
                                            ? _strengthColor
                                            : context.appBorder,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              _ruleRow('At least 8 characters', _hasMinLength),
                              const SizedBox(height: 6),
                              _ruleRow(
                                'Includes uppercase letter and number',
                                _hasUpperAndNumber,
                              ),
                              const SizedBox(height: 6),
                              _ruleRow('Passwords match', _passwordsMatch),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm password
                        Text(
                          'Confirm New Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: context.appMutedText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _passwordField(
                          controller: _confirmPasswordController,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appAccent,
                              foregroundColor: context.appOnAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: const Color(
                                0xFF12562B,
                              ).withValues(alpha: 0.3),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Reset Password & Log In',
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Security badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield, size: 16, color: context.appAccent),
                      SizedBox(width: 6),
                      Text(
                        '256-bit AES Encryption • Privacy Protected',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.appMutedText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Back to login
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (r) => false);
                    },
                    icon: const Icon(Icons.keyboard_backspace, size: 20),
                    label: const Text(
                      'Back to Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: context.appAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

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
          child: Icon(icon, size: 22, color: context.appText),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 16, color: context.appText),
      decoration: InputDecoration(
        hintText: '••••••••••••',
        hintStyle: TextStyle(color: context.appMutedText),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: context.appMutedText,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: context.appMutedText,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: context.appSurfaceContainer,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _ruleRow(String label, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: ok ? context.appAccent : context.appMutedText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ok ? context.appText : context.appMutedText,
            ),
          ),
        ),
      ],
    );
  }
}
