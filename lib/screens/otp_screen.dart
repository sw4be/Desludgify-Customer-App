import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'package:flutter/services.dart';
import '../widgets/app_brand_logo.dart';
import 'auth_store.dart';

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Future<void> _verifyAndCreateAccount() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code')),
      );
      return;
    }
    if (otp != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That verification code is incorrect.')),
      );
      return;
    }
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (arguments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration details are missing.')),
      );
      return;
    }
    final registered = await AuthStore.register(
      AppUser(
        name: arguments['name'] ?? '',
        phone: arguments['phone'] ?? '',
        email: arguments['email'] ?? '',
        password: arguments['password'] ?? '',
        address: arguments['address'] ?? '',
        latitude: double.tryParse(arguments['latitude'] ?? ''),
        longitude: double.tryParse(arguments['longitude'] ?? ''),
        profileImagePath: arguments['profileImagePath']?.isNotEmpty == true
            ? arguments['profileImagePath']
            : null,
      ),
    );
    if (!mounted) return;
    if (!registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An account with this email already exists.'),
        ),
      );
      return;
    }
    // A successfully verified new account is signed in for the next launch.
    await AuthStore.signIn(
      arguments['email'] ?? '',
      arguments['password'] ?? '',
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/account-created',
      (route) => false,
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (index == 5 && value.isNotEmpty) {
      final otp = _otpControllers.map((c) => c.text).join();
      if (otp.length == 6) {
        // optional auto-submit
      }
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _otpControllers[index - 1].clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final phone = arguments?['phone'] ?? 'your phone number';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      backgroundColor: context.appSurfaceContainer,
                      color: context.appAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '5/5',
                    style: TextStyle(
                      color: context.appAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF94F4AD).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 48,
                  color: context.appAccent,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Verify Your Identity",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Enter the 6-digit verification code for\n$phone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: context.appMutedText,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Demo OTP: 123456',
                style: TextStyle(
                  color: context.appAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 18, color: context.appAccent),
                  SizedBox(width: 8),
                  Text(
                    "Expires in 01:59",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.appText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {},
                child: Text(
                  "Resend Code",
                  style: TextStyle(
                    color: context.appAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _verifyAndCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appAccent,
                    foregroundColor: context.appOnAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Verify & Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: Text(
                  "Contact Support",
                  style: TextStyle(
                    color: context.appAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://picsum.photos/id/1015/600/200',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 130,
                    color: context.appSurfaceContainer,
                    child: Center(child: const AppBrandLogo(size: 56)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Secured by Deslugify Core",
                style: TextStyle(fontSize: 12, color: context.appMutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyPressed(index, event),
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.appText,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appAccent, width: 2),
            ),
          ),
          onChanged: (value) => _onOtpChanged(index, value),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.close, color: context.appText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const AppBrandLogo(size: 32),
          const SizedBox(width: 8),
          Text(
            'Deslugify',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }
}
