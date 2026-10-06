import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_brand_logo.dart';
import 'theme_colors.dart';

class VerificationNotificationScreen extends StatefulWidget {
  const VerificationNotificationScreen({super.key});

  @override
  State<VerificationNotificationScreen> createState() =>
      _VerificationNotificationScreenState();
}

class _VerificationNotificationScreenState
    extends State<VerificationNotificationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _scanController;
  late final AnimationController _spinController;
  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scanController.dispose();
    _spinController.dispose();
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Top App Bar ────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.75),
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Row(
                  children: [
                    const AppBrandLogo(width: 36, height: 36),
                    const SizedBox(width: 8),
                    Text(
                      'Deslugify',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.support_agent,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 26,
                    ),
                  ),
                ],
              ),

              // ── Body ───────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Radar + steps card
                    _buildRadarCard(),
                    const SizedBox(height: 16),

                    // Notification banner
                    _buildNotificationBanner(),
                    const SizedBox(height: 20),

                    // CTA buttons
                    _buildCtaButtons(),
                  ]),
                ),
              ),
            ],
          ),

          // Bottom nav
          Positioned(left: 16, right: 16, bottom: 16, child: _buildBottomNav()),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.appAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.appAccent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 16, color: context.appAccent),
              SizedBox(width: 6),
              Text(
                'Images Submitted Successfully',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.appAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'AI Verification in Progress',
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
          'Our eco-tech diagnostic model is inspecting your septic tank scans for structural integrity and sediment depth.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: context.appMutedText,
          ),
        ),
      ],
    );
  }

  // ── Radar + pipeline card ──────────────────────────────────────────────

  Widget _buildRadarCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12562B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                // Radar
                _buildRadar(),
                const SizedBox(height: 28),
                Divider(color: context.appBorder),
                const SizedBox(height: 16),

                // Steps
                _buildStep(
                  status: _StepStatus.completed,
                  title: '1. Images Received & Validated',
                  subtitle:
                      '3 high-res site photos uploaded with GPS metadata.',
                  statusLabel: 'Completed',
                ),
                const SizedBox(height: 16),
                _buildStep(
                  status: _StepStatus.inProgress,
                  title: '2. AI Image Integrity Check',
                  subtitle:
                      'Scanning for surface scum, sludge levels & pipe corrosion.',
                  statusLabel: 'In Progress',
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: 0.6,
                  child: _buildStep(
                    status: _StepStatus.queued,
                    title: '3. Issue & Urgency Assessment',
                    subtitle:
                        'Generating pump-out urgency score & technician dispatch plan.',
                    statusLabel: 'Queued',
                  ),
                ),
              ],
            ),
          ),

          // Footer estimate
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: context.appSurfaceContainer,
              border: Border(top: BorderSide(color: context.appBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: context.appAccent),
                    SizedBox(width: 6),
                    Text(
                      'Estimated processing time:',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
                Text(
                  '1 - 2 minutes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadar() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowController,
        _scanController,
        _spinController,
        _pingController,
      ]),
      builder: (context, _) {
        final glow = 0.4 + (_glowController.value * 0.35);
        final scale = 1.0 + (_glowController.value * 0.02);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appSurfaceContainer,
              border: Border.all(
                color: context.appAccent.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF94F4AD).withValues(alpha: glow),
                  blurRadius: 15 + (_glowController.value * 15),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF006D38).withValues(alpha: glow * 0.5),
                  blurRadius: 30 + (_glowController.value * 15),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dashed rotating ring
                Transform.rotate(
                  angle: _spinController.value * 6.2832,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.appAccent.withValues(alpha: 0.35),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    // Fake dashed look with CustomPaint would be ideal;
                    // solid ring is fine for mobile.
                  ),
                ),

                // Scan line
                Positioned(
                  top: 12 + (_scanController.value * 88),
                  left: 14,
                  right: 14,
                  child: Opacity(
                    opacity: _scanController.value < 0.5
                        ? 0.8 - _scanController.value * 0.5
                        : 0.3 + (_scanController.value - 0.5) * 1.0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            context.appAccent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Core icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.document_scanner,
                    color: context.appOnAccent,
                    size: 28,
                  ),
                ),

                // Analyzing badge
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.appAccent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF96F7B0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF96F7B0,
                                ).withValues(alpha: 1 - _pingController.value),
                                blurRadius: 4,
                                spreadRadius: _pingController.value * 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'ANALYZING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: context.appOnAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep({
    required _StepStatus status,
    required String title,
    required String subtitle,
    required String statusLabel,
  }) {
    Widget icon;
    Color statusColor;

    switch (status) {
      case _StepStatus.completed:
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: context.appAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14, color: context.appOnAccent),
        );
        statusColor = context.appAccent;
        break;
      case _StepStatus.inProgress:
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: context.appAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: context.appAccent),
          ),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.appAccent,
            ),
          ),
        );
        statusColor = context.appText;
        break;
      case _StepStatus.queued:
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: context.appSurfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hourglass_empty,
            size: 14,
            color: context.appMutedText,
          ),
        );
        statusColor = context.appMutedText;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: status == _StepStatus.queued
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: status == _StepStatus.queued
                            ? context.appMutedText
                            : context.appText,
                      ),
                    ),
                  ),
                  if (status == _StepStatus.inProgress)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: context.appAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: context.appMutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Notification banner ────────────────────────────────────────────────

  Widget _buildNotificationBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_active,
              color: context.appAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You don't have to stay on this screen",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We'll notify you automatically via in-app alert and push notification once your diagnosis is ready.",
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CTAs ───────────────────────────────────────────────────────────────

  Widget _buildCtaButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/pending-requests');
            },
            icon: const Icon(Icons.query_stats, size: 22),
            label: const Text(
              'View Service Requests / Track Status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appAccent,
              foregroundColor: context.appOnAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF12562B).withValues(alpha: 0.25),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            icon: const Icon(Icons.home, size: 20),
            label: const Text(
              'Back to Home',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appAccent,
              backgroundColor: context.appSurface,
              side: BorderSide(color: context.appBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 1, overlay: true);
  }
}

enum _StepStatus { completed, inProgress, queued }
