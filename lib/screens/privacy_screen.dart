import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_brand_logo.dart';
import 'theme_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _loading = true;

  bool _shareLocation = true;
  bool _shareProfilePhoto = true;
  bool _allowTechnicianContact = true;
  bool _analytics = false;
  bool _personalizedTips = true;
  bool _showOnlineStatus = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _shareLocation = p.getBool('privacy_share_location') ?? true;
      _shareProfilePhoto = p.getBool('privacy_share_photo') ?? true;
      _allowTechnicianContact = p.getBool('privacy_allow_contact') ?? true;
      _analytics = p.getBool('privacy_analytics') ?? false;
      _personalizedTips = p.getBool('privacy_tips') ?? true;
      _showOnlineStatus = p.getBool('privacy_online') ?? false;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('privacy_share_location', _shareLocation);
    await p.setBool('privacy_share_photo', _shareProfilePhoto);
    await p.setBool('privacy_allow_contact', _allowTechnicianContact);
    await p.setBool('privacy_analytics', _analytics);
    await p.setBool('privacy_tips', _personalizedTips);
    await p.setBool('privacy_online', _showOnlineStatus);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Privacy settings saved')));
    Navigator.pop(context);
  }

  Future<void> _onShareLocationChanged(bool value) async {
    if (value) {
      // Turning ON → request system location permission
      final ok = await _requestLocationPermission();
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied. Enable it in phone Settings.',
            ),
          ),
        );
        setState(() => _shareLocation = false);
        final p = await SharedPreferences.getInstance();
        await p.setBool('privacy_share_location', false);
        return;
      }
    }

    setState(() => _shareLocation = value);
    final p = await SharedPreferences.getInstance();
    await p.setBool('privacy_share_location', value);
  }

  Future<bool> _requestLocationPermission() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turn on Location in phone Settings')),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF08090A) : const Color(0xFFF8FAF3);
    final card = isDark ? const Color(0xFF17181C) : Colors.white;
    final text = isDark ? const Color(0xFFF5F6F7) : const Color(0xFF003D1A);
    final muted = isDark ? const Color(0xFFB0B4BC) : const Color(0xFF707970);
    final border = isDark ? const Color(0xFF3A3D44) : const Color(0xFFE8EBE6);
    final accent = isDark ? const Color(0xFFE8EAED) : const Color(0xFF006D38);

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF08090A) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? accent : const Color(0xFF003D1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const AppBrandLogo(size: 26),
            const SizedBox(width: 8),
            Text(
              'Privacy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? accent : const Color(0xFF003D1A),
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
              'Control how your data is used and who can see your information.',
              style: TextStyle(fontSize: 14, color: muted, height: 1.4),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Location & profile', text),
            const SizedBox(height: 10),
            _card(
              card,
              border,
              children: [
                _switchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Share location for service',
                  subtitle: 'Needed so teams can find your site',
                  value: _shareLocation,
                  text: text,
                  muted: muted,
                  onChanged: _onShareLocationChanged,
                ),
                _divider(border),
                _switchTile(
                  icon: Icons.photo_outlined,
                  title: 'Show profile photo to technicians',
                  subtitle: 'Helps field teams identify you',
                  value: _shareProfilePhoto,
                  text: text,
                  muted: muted,
                  onChanged: (v) async {
                    setState(() => _shareProfilePhoto = v);
                    final p = await SharedPreferences.getInstance();
                    await p.setBool('privacy_share_photo', v);
                  },
                ),
                _divider(border),
                _switchTile(
                  icon: Icons.phone_outlined,
                  title: 'Allow technician contact',
                  subtitle: 'Call or message for your active jobs',
                  value: _allowTechnicianContact,
                  text: text,
                  muted: muted,
                  onChanged: (v) async {
                    setState(() => _allowTechnicianContact = v);
                    final p = await SharedPreferences.getInstance();
                    await p.setBool('privacy_allow_contact', v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            _sectionTitle('App & data', text),
            const SizedBox(height: 10),
            _card(
              card,
              border,
              children: [
                _switchTile(
                  icon: Icons.analytics_outlined,
                  title: 'Usage analytics',
                  subtitle: 'Help improve Deslugify (anonymous)',
                  value: _analytics,
                  text: text,
                  muted: muted,
                  onChanged: (v) async {
                    setState(() => _analytics = v);
                    final p = await SharedPreferences.getInstance();
                    await p.setBool('privacy_analytics', v);
                  },
                ),
                _divider(border),
                _switchTile(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Personalized eco tips',
                  subtitle: 'Based on your request history',
                  value: _personalizedTips,
                  text: text,
                  muted: muted,
                  onChanged: (v) async {
                    setState(() => _personalizedTips = v);
                    final p = await SharedPreferences.getInstance();
                    await p.setBool('privacy_tips', v);
                  },
                ),
                _divider(border),
                _switchTile(
                  icon: Icons.circle_outlined,
                  title: 'Show online status',
                  subtitle: 'Visible only during active service',
                  value: _showOnlineStatus,
                  text: text,
                  muted: muted,
                  onChanged: (v) async {
                    setState(() => _showOnlineStatus = v);
                    final p = await SharedPreferences.getInstance();
                    await p.setBool('privacy_online', v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            _sectionTitle('Your data', text),
            const SizedBox(height: 10),
            _card(
              card,
              border,
              children: [
                _linkTile(
                  icon: Icons.download_outlined,
                  title: 'Download my data',
                  subtitle: 'Request a copy of your account data',
                  text: text,
                  muted: muted,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data export request submitted (demo)'),
                      ),
                    );
                  },
                ),
                _divider(border),
                _linkTile(
                  icon: Icons.delete_outline,
                  title: 'Delete account',
                  subtitle: 'Permanently remove your account',
                  text: const Color(0xFFBA1A1A),
                  muted: muted,
                  onTap: () => _confirmDelete(context, isDark, card, text),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _card(
              card,
              border,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(Icons.description_outlined, color: muted),
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w500, color: text),
                  ),
                  trailing: Icon(Icons.chevron_right, color: muted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open Privacy Policy (demo)'),
                      ),
                    );
                  },
                ),
                _divider(border),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(Icons.gavel_outlined, color: muted),
                  title: Text(
                    'Terms of Service',
                    style: TextStyle(fontWeight: FontWeight.w500, color: text),
                  ),
                  trailing: Icon(Icons.chevron_right, color: muted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open Terms of Service (demo)'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appAccent,
                  foregroundColor: context.appOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    bool isDark,
    Color card,
    Color text,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? card : null,
        title: Text('Delete account?', style: TextStyle(color: text)),
        content: Text(
          'This cannot be undone. All requests and profile data will be removed.',
          style: TextStyle(color: isDark ? const Color(0xFF9AA39A) : null),
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
                const SnackBar(content: Text('Account deletion is demo-only')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFBA1A1A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _card(Color card, Color border, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color text,
    required Color muted,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Icon(icon, color: muted),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: text,
          fontSize: 15,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
      value: value,
      activeThumbColor: const Color(0xFF006D38),
      activeTrackColor: const Color(0xFF94F4AD),
      onChanged: onChanged,
    );
  }

  Widget _linkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color text,
    required Color muted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: text == const Color(0xFFBA1A1A) ? text : muted,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: text),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
      trailing: Icon(Icons.chevron_right, color: muted),
      onTap: onTap,
    );
  }

  Widget _divider(Color border) =>
      Divider(height: 1, indent: 16, endIndent: 16, color: border);
}
