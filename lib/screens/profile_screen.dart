import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/app_bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'auth_store.dart';
import 'theme_colors.dart';
import 'theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  AppUser? _user;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    AuthStore.currentUser().then((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  Future<void> _saveUser(AppUser updated) async {
    final oldEmail = _user?.email;
    if (oldEmail == null) return;
    final saved = await AuthStore.saveUser(updated, previousEmail: oldEmail);
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That email is already in use.')),
      );
      return;
    }
    setState(() => _user = updated);
  }

  Future<String?> _askForText(String title, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: title == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> _editName() async {
    final user = _user;
    if (user == null) return;
    final name = await _askForText('Full Name', user.name);
    if (name == null || name.isEmpty) return;
    await _saveUser(user.copyWith(name: name));
  }

  Future<void> _editEmail() async {
    final user = _user;
    if (user == null) return;
    final email = await _askForText('Email', user.email);
    if (email == null || !email.contains('@')) return;
    await _saveUser(user.copyWith(email: email));
  }

  Future<void> _editPhone() async {
    final user = _user;
    if (user == null) return;
    final phone = await _askForText('Phone Number', user.phone);
    if (!mounted || phone == null || phone.isEmpty || phone == user.phone) {
      return;
    }
    final codeController = TextEditingController();
    final verified = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify phone number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the verification code sent to $phone.'),
            const SizedBox(height: 12),
            const Text('Demo verification code: 123456'),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: '6-digit code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              codeController.text.trim() == '123456',
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    codeController.dispose();
    if (verified == true) await _saveUser(user.copyWith(phone: phone));
  }

  Future<void> _editAddress() async {
    final user = _user;
    if (user == null) return;
    final selected =
        await showDialog<({String address, double latitude, double longitude})>(
          context: context,
          builder: (dialogContext) => _AddressPickerDialog(
            initialAddress: user.address,
            initialLatitude: user.latitude,
            initialLongitude: user.longitude,
          ),
        );
    if (selected == null) return;
    await _saveUser(
      user.copyWith(
        address: selected.address,
        latitude: selected.latitude,
        longitude: selected.longitude,
      ),
    );
  }

  Future<void> _selectProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    await _saveProfileImage(image);
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    await _saveProfileImage(image);
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfileImage(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final extension = image.path.contains('.')
          ? image.path.substring(image.path.lastIndexOf('.'))
          : '.jpg';
      final savedFile = await File(image.path).copy(
        '${directory.path}/profile_${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      if (_user == null) _user = await AuthStore.currentUser();
      final user = _user;
      if (user != null) {
        await _saveUser(user.copyWith(profileImagePath: savedFile.path));
      }
      if (mounted) setState(() => _profileImage = savedFile);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the profile photo.')),
      );
    }
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

    final iconBg = isDark
        ? const Color(0xFF94F4AD).withValues(alpha: 0.15)
        : const Color(0xFF94F4AD).withValues(alpha: 0.25);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF08090A) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: Row(
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? accent : const Color(0xFF003D1A),
              ),
            ),
          ],
        ),

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),

        child: Column(
          children: [
            _buildProfileHeader(text, muted),

            const SizedBox(height: 28),

            _buildContactInfo(card, border, text, muted, accent, iconBg),

            const SizedBox(height: 28),

            _buildSettingsSection(context, card, border, text, muted, accent),

            const SizedBox(height: 32),

            _buildLogoutButton(context),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileHeader(Color text, Color muted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storedImagePath = _user?.profileImagePath;
    final profileImage = _profileImage ??
        (storedImagePath == null ? null : File(storedImagePath));
    final hasProfileImage = profileImage?.existsSync() ?? false;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _selectProfilePicture,

              child: Container(
                width: 120,
                height: 120,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(color: Colors.white, width: 4),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),

                  child: hasProfileImage
                      ? Image.file(profileImage!, fit: BoxFit.cover)
                      : Container(
                          color: isDark
                              ? const Color(0xFF2A332C)
                              : const Color(0xFFE1E3DD),

                          child: Icon(
                            Icons.person,
                            size: 55,
                            color: isDark
                                ? const Color(0xFF94F4AD)
                                : const Color(0xFF006D38),
                          ),
                        ),
                ),
              ),
            ),

            Positioned(
              bottom: 2,
              right: 2,

              child: GestureDetector(
                onTap: _selectProfilePicture,

                child: Container(
                  padding: const EdgeInsets.all(7),

                  decoration: BoxDecoration(
                    color: const Color(0xFF006D38),
                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(color: Colors.white, width: 2),
                  ),

                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        InkWell(
          onTap: _editName,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _user?.name ?? 'Loading profile...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined, size: 16, color: muted),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Text(_user?.email ?? '', style: TextStyle(fontSize: 15, color: muted)),
      ],
    );
  }

  Widget _buildContactInfo(
    Color card,
    Color border,
    Color text,
    Color muted,
    Color accent,
    Color iconBg,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _contactCard(
                Icons.email_outlined,
                "Email",
                _user?.email ?? '',
                card,
                border,
                text,
                muted,
                accent,
                iconBg,
                onTap: _editEmail,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _contactCard(
                Icons.phone_outlined,
                "Phone",
                _user?.phone.isNotEmpty == true
                    ? _user!.phone
                    : 'Add phone number',
                card,
                border,
                text,
                muted,
                accent,
                iconBg,
                onTap: _editPhone,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _contactCard(
          Icons.location_on_outlined,
          "Home Address",
          _user?.address.isNotEmpty == true
              ? _user!.address
              : 'Add home address',
          card,
          border,
          text,
          muted,
          accent,
          iconBg,
          onTap: _editAddress,
        ),
      ],
    );
  }

  Widget _contactCard(
    IconData icon,
    String label,
    String value,
    Color card,
    Color border,
    Color text,
    Color muted,
    Color accent,
    Color iconBg, {
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(icon, color: accent, size: 22),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: muted)),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    Color card,
    Color border,
    Color text,
    Color muted,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),

          child: Text(
            "Account Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),

          child: Column(
            children: [
              _settingsTile(
                Icons.notifications_outlined,
                "Notification preferences",
                text: text,
                muted: muted,
                onTap: () {
                  Navigator.pushNamed(context, '/notification-preferences');
                },
              ),

              _divider(border),

              _settingsTile(
                Icons.lock_outline,
                "Security",
                subtitle: "Change Password & 2FA",
                text: text,
                muted: muted,
                onTap: () {
                  Navigator.pushNamed(context, '/security');
                },
              ),

              _divider(border),

              _settingsTile(
                Icons.palette_outlined,
                "App Theme",
                text: text,
                muted: muted,

                trailing: ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.themeMode,

                  builder: (context, mode, _) {
                    final label = switch (mode) {
                      ThemeMode.dark => 'Dark Mode',
                      ThemeMode.system => 'System',
                      _ => 'Light Mode',
                    };

                    return Text(
                      label,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    );
                  },
                ),

                onTap: () => _showThemeDialog(context),
              ),

              _divider(border),

              _settingsTile(
                Icons.visibility_outlined,
                "Privacy",
                text: text,
                muted: muted,
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        title: const Text('App Theme'),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            ListTile(
              leading: Icon(Icons.light_mode, color: context.appAccent),

              title: const Text('Light Mode'),

              onTap: () async {
                await ThemeController.setLight();
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Light Mode selected')),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.dark_mode, color: context.appAccent),

              title: const Text('Dark Mode'),

              onTap: () async {
                await ThemeController.setDark();
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark Mode selected')),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.brightness_auto, color: context.appAccent),

              title: const Text('System Default'),

              onTap: () async {
                await ThemeController.setSystem();
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('System Default selected')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required Color text,
    required Color muted,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),

      leading: Icon(icon, color: muted),

      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: text),
      ),

      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 13, color: muted))
          : null,

      trailing: trailing ?? Icon(Icons.chevron_right, color: muted),

      onTap: onTap,
    );
  }

  Widget _divider(Color border) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: border);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,

            builder: (ctx) => AlertDialog(
              title: const Text("Logout"),

              content: const Text("Are you sure you want to logout?"),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),

                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await AuthStore.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/landing',
                      (route) => false,
                    );
                  },

                  child: Text(
                    "Logout",
                    style: TextStyle(color: context.appError),
                  ),
                ),
              ],
            ),
          );
        },

        icon: Icon(Icons.logout, color: context.appError),

        label: Text(
          "Logout",
          style: TextStyle(
            color: context.appError,
            fontWeight: FontWeight.w600,
          ),
        ),

        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),

          side: BorderSide(color: context.appError, width: 1.5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 4);
  }
}

class _AddressPickerDialog extends StatefulWidget {
  final String initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const _AddressPickerDialog({
    required this.initialAddress,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<_AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<_AddressPickerDialog> {
  static const _defaultCenter = LatLng(14.5995, 120.9842);
  late final TextEditingController _addressController = TextEditingController(
    text: widget.initialAddress,
  );
  LatLng? _pin;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pin = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _pin ?? _defaultCenter;
    return AlertDialog(
      title: const Text('Pin your home address'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Home address'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14,
                  onTap: (_, point) => setState(() => _pin = point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.clientapp',
                    maxZoom: 19,
                  ),
                  if (_pin != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pin!,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _pin == null
                  ? 'Tap the map to place a pin before saving.'
                  : 'Pinned: ${_pin!.latitude.toStringAsFixed(5)}, ${_pin!.longitude.toStringAsFixed(5)}',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _pin == null || _addressController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (
                  address: _addressController.text.trim(),
                  latitude: _pin!.latitude,
                  longitude: _pin!.longitude,
                )),
          child: const Text('Save address'),
        ),
      ],
    );
  }
}
