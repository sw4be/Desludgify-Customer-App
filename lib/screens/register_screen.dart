import 'dart:io';
import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'location_service.dart';
import '../widgets/app_brand_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  int _currentStep = 0;
  bool _locationPermissionGranted = false;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _locatingAddress = false;
  bool _showLocationMap = false;
  LatLng? _selectedLocation;
  String? _locationStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openLocationMap() async {
    if (_locatingAddress) return;
    setState(() {
      _locatingAddress = true;
      _locationStatus = 'Detecting your location...';
      _showLocationMap = true;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(
          () => _locationStatus = 'Tap the map to choose your address.',
        );
        return;
      }
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = location;
        _locationPermissionGranted = true;
        _addressController.text = _formatCoordinates(location);
        _locationStatus = 'Current location detected.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () =>
            _locationStatus = 'Location unavailable. Tap the map to choose.',
      );
    } finally {
      if (mounted) setState(() => _locatingAddress = false);
    }
  }

  String _formatCoordinates(LatLng location) =>
      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

  void _selectMapLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _addressController.text = _formatCoordinates(location);
      _locationStatus = 'Map location selected.';
    });
  }

  Future<void> _pickProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: context.appAccent),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: context.appAccent),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (picked == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final extension = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final savedImage = await File(picked.path).copy(
      '${directory.path}/registration_${DateTime.now().microsecondsSinceEpoch}$extension',
    );

    setState(() {
      _profileImage = savedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                color: const Color(0xFF94F4AD).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF93D69E).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildProgressIndicator(),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: context.appBorder),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF12562B).withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        _buildCurrentStep(),
                        const SizedBox(height: 24),
                        _buildContinueButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const titles = ['Basic Info', 'Create Password', 'Address', 'Photo + T&Cs'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: _currentStep == 0 ? 'Back' : 'Previous step',
              onPressed: () {
                if (_currentStep == 0) {
                  Navigator.maybePop(context);
                } else {
                  setState(() => _currentStep--);
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                titles[_currentStep],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.appText,
                ),
              ),
            ),
            Text(
              '${_currentStep + 1}/4',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 6,
            backgroundColor: context.appSurfaceContainer,
            color: context.appAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            _buildInputField(
              label: 'Full Name', icon: Icons.person_outline,
              hint: 'John Doe', controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Email', icon: Icons.mail_outline,
              hint: 'john@example.com', controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Phone Number (for OTP)', icon: Icons.phone_outlined,
              hint: '+1 (555) 000-0000', controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildPasswordField(
              label: 'Password', controller: _passwordController,
              obscure: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              showStrength: true,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Confirm Password', controller: _confirmPasswordController,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your home address and allow location access to place a geo-tag on the map.',
              style: TextStyle(color: context.appMutedText, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildAddressField(),
          ],
        );
      default:
        return Column(
          children: [
            _buildProfilePicture(),
            const SizedBox(height: 8),
            Text(
              'Optional. You can add a profile photo later.',
              style: TextStyle(fontSize: 12, color: context.appMutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTermsCheckbox(),
          ],
        );
    }
  }

  void _continueRegistration() {
    String? error;
    switch (_currentStep) {
      case 0:
        final email = _emailController.text.trim();
        if (_nameController.text.trim().isEmpty ||
            !email.contains('@') ||
            _phoneController.text.trim().isEmpty) {
          error = 'Enter your full name, valid email, and phone number.';
        }
        break;
      case 1:
        if (_passwordController.text.length < 8 ||
            _passwordController.text != _confirmPasswordController.text) {
          error = 'Use an 8-character password and confirm it.';
        }
        break;
      case 2:
        if (!_locationPermissionGranted || _selectedLocation == null) {
          error = 'Use Location and allow permission to add a map pin.';
        } else if (_addressController.text.trim().isEmpty) {
          error = 'Enter your home address.';
        }
        break;
      case 3:
        if (!_agreedToTerms) {
          error = 'Please agree to the Terms and Privacy Policy.';
        } else {
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'address': _addressController.text.trim(),
              'latitude': _selectedLocation!.latitude.toString(),
              'longitude': _selectedLocation!.longitude.toString(),
              'profileImagePath': _profileImage?.path ?? '',
            },
          );
          return;
        }
        break;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _currentStep++);
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _continueRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.appAccent,
          foregroundColor: context.appOnAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _currentStep == 3 ? 'Continue to Phone Verification' : 'Continue',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.appText,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AppBrandLogo(size: 36),
            ),
            const SizedBox(width: 12),
            Text(
              "Deslugify",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: context.appText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.appText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          "Join the smart environmental revolution.",
          style: TextStyle(fontSize: 15, color: context.appMutedText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appSurfaceContainer,
                  border: Border.all(color: context.appBorder, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                    ),
                  ],
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profileImage == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        color: context.appAccent,
                        size: 28,
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.appAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.appBorder, width: 2),
                ),
                child: Icon(Icons.edit, color: context.appOnAccent, size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _profileImage == null ? "Upload Profile Photo" : "Change Photo",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.appMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: context.appMutedText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: context.appMutedText),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    bool showStrength = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.lock_outline, color: context.appMutedText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  onChanged: showStrength ? (_) => setState(() {}) : null,
                  decoration: const InputDecoration(
                    hintText: "••••••••",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: context.appMutedText,
                  size: 22,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
        if (showStrength) ...[
          const SizedBox(height: 8),
          PasswordStrengthIndicator(password: controller.text),
        ],
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            "Address",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appBorder),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    Icons.location_on_outlined,
                    color: context.appMutedText,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  if (!_showLocationMap)
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "123 Eco Way, Green City",
                          hintStyle: TextStyle(color: context.appMutedText),
                          border: InputBorder.none,
                        ),
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _locationStatus ?? 'Choose your location on the map.',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appMutedText,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _locatingAddress
                        ? null
                        : _openLocationMap,
                    icon: _locatingAddress
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: const Text('Use Location'),
                  ),
                ],
              ),
              if (_showLocationMap) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: FlutterMap(
                      key: ValueKey(_selectedLocation),
                      options: MapOptions(
                        initialCenter: _selectedLocation ??
                            const LatLng(14.5995, 120.9842),
                        initialZoom: _selectedLocation == null ? 11 : 15,
                        onTap: (_, point) => _selectMapLocation(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.clientapp',
                          maxZoom: 19,
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 38,
                                ),
                              ),
                            ],
                          ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              '© OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Current address',
                    hintText: 'Tap the map to select a location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: context.appSurfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
            activeColor: context.appAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                text: "I agree to the ",
                style: TextStyle(fontSize: 13, color: context.appMutedText),
                children: [
                  TextSpan(
                    text: "Terms and Conditions",
                    style: TextStyle(
                      color: context.appAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: " and the "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: context.appAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Text.rich(
        TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: context.appMutedText),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: context.appAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      context.appAccent,
    ];
    final label = password.isEmpty
        ? 'Password strength'
        : ['Weak', 'Fair', 'Good', 'Strong'][score - 1 < 0 ? 0 : score - 1];
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  child: _bar(
                    index < score ? colors[score - 1] : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.appMutedText),
        ),
      ],
    );
  }

  Widget _bar(Color color) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
