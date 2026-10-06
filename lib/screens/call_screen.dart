import 'package:flutter/material.dart';
import 'dart:async';
import 'theme_colors.dart';
import '../widgets/app_brand_logo.dart';

class LiveCallScreen extends StatefulWidget {
  const LiveCallScreen({super.key});

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _seconds = 165; // 2:45
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTimer();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final mins = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Status
              _buildCallStatus(),
              const SizedBox(height: 40),

              // Technician Profile
              _buildTechnicianProfile(),
              const Spacer(),

              // Call Controls
              _buildCallControls(),
            ],
          ),
        ),
      ),
      bottomSheet: _buildServiceInfoPanel(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: Row(
        children: [
          const AppBrandLogo(size: 32),
          const SizedBox(width: 8),
          const Text(
            'Deslugify',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildCallStatus() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF94F4AD),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94F4AD).withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "IN CALL",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appAccent,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _formattedTime,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: context.appText,
          ),
        ),
        Text(
          "Sipsip Poso Negro Service Call",
          style: TextStyle(fontSize: 16, color: context.appMutedText),
        ),
      ],
    );
  }

  Widget _buildTechnicianProfile() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 1 - _pulseAnimation.value,
                  child: Container(
                    width: 220 + (_pulseAnimation.value * 60),
                    height: 220 + (_pulseAnimation.value * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF94F4AD).withValues(alpha: 0.25),
                    ),
                  ),
                );
              },
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF94F4AD), width: 6),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCC87b4fL-QHRge9ejjOYqJVXkXIxl6ZwWTHVk9DZODcxOvG4VXMvaP89Qpv3bPRF4s3L0uT2xzPQGI6C9oVJHboCl9V_hJXfFpih3-F0_ozbgmRv2gTVqGi3U5kStPOK92hTH7P1j3pbaXvuP9t8ZEBhlhBB5IldrK2yU9_N1_X--f6Nb-raYpJvcBoc0O4pVJ7ZWfZJ5DjU_nNS4qXEPdsqP43BSquWmAfBGUi_BAIS32A9mZZQltsr9sUY7_MFRbAZOEZKnCo5r1',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 80, color: context.appMutedText),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Marcus Thorne",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        Text(
          "Lead Technician • SR-2026-001",
          style: TextStyle(
            color: context.appAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCallControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CallControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              label: "Mute",
              isActive: _isMuted,
              onTap: () => setState(() => _isMuted = !_isMuted),
            ),
            _CallControlButton(
              icon: Icons.volume_up,
              label: "Speaker",
              isActive: _isSpeakerOn,
              onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
            ),
            _CallControlButton(
              icon: Icons.dialpad,
              label: "Keypad",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 40),
        // End Call Button
        Semantics(
          button: true,
          label: 'End call',
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFBA1A1A),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 20)],
              ),
              child: const Icon(Icons.call_end, color: Colors.white, size: 36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfoPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status", style: TextStyle(fontSize: 13)),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: context.appAccent),
                        SizedBox(width: 6),
                        Text(
                          "In Progress",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Arrival", style: TextStyle(fontSize: 13)),
                    Text(
                      "Arrived",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.appAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on, color: context.appAccent),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Service Address", style: TextStyle(fontSize: 13)),
                    Text(
                      "123 Emerald Skyway, Green Sector",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive
                    ? context.appAccent.withValues(alpha: 0.15)
                    : context.appSurface,
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? Border.all(color: context.appAccent, width: 2)
                    : null,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isActive ? context.appAccent : context.appText,
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, color: context.appText)),
          ],
        ),
      ),
    );
  }
}
