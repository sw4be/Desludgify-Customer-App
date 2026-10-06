import 'package:flutter/material.dart';
import '../widgets/app_brand_logo.dart';
import 'auth_store.dart';
import 'theme_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const AppBrandLogo(size: 26),
            const SizedBox(width: 8),
            Text(
              'Security',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.appText,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your password and account protection settings.',
              style: TextStyle(
                fontSize: 14,
                color: context.appMutedText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Change Password
            _sectionTitle('Change Password'),
            const SizedBox(height: 10),
            _card(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      _passwordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscure: _obscureCurrent,
                        onToggle: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                      ),
                      const SizedBox(height: 14),
                      _passwordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscure: _obscureNew,
                        onToggle: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),
                      const SizedBox(height: 14),
                      _passwordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        onToggle: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appAccent,
                            foregroundColor: context.appOnAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Update Password',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),

            const SizedBox(height: 24),

            // Protection
            _sectionTitle('Account Protection'),
            const SizedBox(height: 10),
            _card(
              children: [
                _switchTile(
                  icon: Icons.phonelink_lock_outlined,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Extra security with a verification code',
                  value: _twoFactorEnabled,
                  onChanged: (v) {
                    setState(() => _twoFactorEnabled = v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Two-Factor Authentication enabled'
                              : 'Two-Factor Authentication disabled',
                        ),
                      ),
                    );
                  },
                ),
                _divider(),
                _switchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face unlock',
                  value: _biometricEnabled,
                  onChanged: (v) {
                    setState(() => _biometricEnabled = v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Biometric login enabled'
                              : 'Biometric login disabled',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sessions
            _sectionTitle('Sessions'),
            const SizedBox(height: 10),
            _card(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.appAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.devices_outlined,
                      color: context.appAccent,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Log out of all devices',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.appText,
                    ),
                  ),
                  subtitle: Text(
                    'Sign out everywhere except this phone',
                    style: TextStyle(fontSize: 13, color: context.appMutedText),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.appMutedText,
                  ),
                  onTap: _logoutAllDevices,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    final user = await AuthStore.currentUser();
    if (!mounted) return;
    if (user == null || user.password != _currentPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }
    final saved = await AuthStore.saveUser(
      user.copyWith(password: _newPasswordController.text),
      previousEmail: user.email,
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the password')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _logoutAllDevices() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out all devices?'),
        content: const Text(
          'You will stay signed in on this phone. All other sessions will be ended.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out of all other devices'),
                ),
              );
            },
            child: Text('Confirm', style: TextStyle(color: context.appError)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.appText,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.appText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.appSurfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.lock_outline, color: context.appMutedText, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: context.appMutedText,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.appAccent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: context.appAccent, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.appText,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: context.appMutedText),
      ),
      value: value,
      activeThumbColor: context.appAccent,
      activeTrackColor: context.appAccent.withValues(alpha: 0.35),
      onChanged: onChanged,
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 16, endIndent: 16, color: context.appBorder);
}
