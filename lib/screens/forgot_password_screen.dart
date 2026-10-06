import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_colors.dart';
import '../widgets/app_brand_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    // TODO: call your API to send SMS
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    // Navigate to the password-reset SMS verification screen.
    Navigator.of(context).pushNamed(
      '/password-sms-code',
      arguments: '+63${_phoneController.text.replaceAll(' ', '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -80,
            right: -60,
            child: _blob(200, const Color(0xFF94F4AD).withValues(alpha: 0.3)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: -90,
            child: _blob(220, const Color(0xFFAEF3B9).withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: -40,
            right: 0,
            child: _blob(180, const Color(0xFF96F7B0).withValues(alpha: 0.25)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: context.appBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.appAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ACCOUNT RECOVERY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: context.appMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleBtn(icon: Icons.help_outline, onTap: () {}),
                    ],
                  ),
                ),

                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Logo
                        Container(
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
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const AppBrandLogo(size: 56),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: context.appText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter your registered mobile phone number to receive a verification SMS code to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: context.appMutedText,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form card
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
                                ).withValues(alpha: 0.07),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mobile Phone Number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    color: context.appMutedText,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Phone input with +63 prefix
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.appSurface,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        border: Border.all(
                                          color: context.appBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.smartphone,
                                            size: 18,
                                            color: context.appAccent,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            '+63',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: context.appText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: context.appText,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '917 123 4567',
                                          hintStyle: TextStyle(
                                            color: context.appMutedText,
                                          ),
                                          filled: true,
                                          fillColor: context.appSurface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 15,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight: Radius.circular(
                                                    12,
                                                  ),
                                                ),
                                            borderSide: BorderSide(
                                              color: context.appBorder,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight: Radius.circular(
                                                    12,
                                                  ),
                                                ),
                                            borderSide: BorderSide(
                                              color: context.appBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight: Radius.circular(
                                                    12,
                                                  ),
                                                ),
                                            borderSide: BorderSide(
                                              color: context.appAccent,
                                              width: 1.5,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight: Radius.circular(
                                                    12,
                                                  ),
                                                ),
                                            borderSide: BorderSide(
                                              color: context.appError,
                                            ),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Enter your phone number';
                                          }
                                          if (v.trim().length < 10) {
                                            return 'Enter a valid 10-digit number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: context.appAccent,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'We will send a 6-digit SMS verification code to this number.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.appMutedText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Submit
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.appAccent,
                                      foregroundColor: context.appOnAccent,
                                      disabledBackgroundColor: context.appAccent
                                          .withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 6,
                                      shadowColor: const Color(
                                        0xFF12562B,
                                      ).withValues(alpha: 0.25),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Send Reset SMS Code',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Log in link
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: context.appMutedText,
                            ),
                            children: [
                              const TextSpan(text: 'Remember your password? '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (r) => false,
                                    );
                                  },
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 12),

                        // Support
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.support_agent, size: 18),
                          label: const Text(
                            'Need help? Contact Deslugify Support',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.appMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                              Icons.lock,
                              size: 14,
                              color: context.appAccent,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '256-bit AES Encryption',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appMutedText,
                              ),
                            ),
                            Text(
                              '  •  ',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appMutedText,
                              ),
                            ),
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appMutedText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              '  •  ',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appMutedText,
                              ),
                            ),
                            Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appMutedText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Home indicator
                      Container(
                        width: 128,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.appMutedText.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
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
