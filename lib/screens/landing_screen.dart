import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeslugifyHomeScreen extends StatefulWidget {
  const DeslugifyHomeScreen({super.key});

  @override
  State<DeslugifyHomeScreen> createState() => _DeslugifyHomeScreenState();
}

class _DeslugifyHomeScreenState extends State<DeslugifyHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _spinRevController;
  late final AnimationController _floatController;

  static const String _logoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBlRwEBYfT2jFuRfKmWVywAYWss-5TJMqlb735Z31tIgib2BBXHEfEi6_KfpComqJLl_Y5BDcf1VIg5f5GGRjWSj_nk0QR8-znEI8BKeXQRDu76qwEtYs_qLqqA7JKg6mRkF-dy2V6DGNCQCJr_aLJfYqRfwUUnKU52Ln_FbEKQtZFOoDBVO9f1DfeBZcKFP7E56xffBqLqmSiJqZ-rQMIB3wHulo5xbNpnqZswnfFVv05ezXD-5s_eULAcxwhrbc0fGWu_CGxyW2anr2w';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _spinRevController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _spinRevController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03150A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient glow — center top
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF006D38).withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006D38).withValues(alpha: 0.25),
                        blurRadius: 100,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient glow — bottom right
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF12562B).withValues(alpha: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12562B).withValues(alpha: 0.3),
                      blurRadius: 90,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dot grid
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: const Color(0xFF94F4AD).withValues(alpha: 0.03),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kinetic rings + glass logo
                      SizedBox(
                        width: 288,
                        height: 288,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer dashed ring
                            AnimatedBuilder(
                              animation: _spinController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: _spinController.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: CustomPaint(
                                size: const Size(288, 288),
                                painter: _DashedCirclePainter(
                                  color: const Color(
                                    0xFF96F7B0,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                            ),

                            // Inner ring + node
                            AnimatedBuilder(
                              animation: _spinRevController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle:
                                      -_spinRevController.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                width: 256,
                                height: 256,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF96F7B0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF96F7B0,
                                              ).withValues(alpha: 0.85),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Soft backlight
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(
                                      0xFF12562B,
                                    ).withValues(alpha: 0.4),
                                    const Color(
                                      0xFF006D38,
                                    ).withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Glass card + logo
                            AnimatedBuilder(
                              animation: _floatController,
                              builder: (_, child) {
                                final t = _floatController.value;
                                return Transform.translate(
                                  offset: Offset(0, -4 * t),
                                  child: Transform.scale(
                                    scale: 1 + 0.02 * t,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                width: 176,
                                height: 176,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: RadialGradient(
                                    center: const Alignment(0, -0.8),
                                    radius: 1.2,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.white.withValues(alpha: 0.02),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 48,
                                      offset: const Offset(0, 24),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  _logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/AppLogo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.eco,
                                      size: 64,
                                      color: Color(0xFF94F4AD),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Desludgify',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF96F7B0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'AUTONOMOUS ECO-DESLUDGING',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                          color: const Color(0xFFC0C9BE).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Get Started
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 8,
                          shadowColor: Colors.white.withValues(alpha: 0.15),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/login');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191D19),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Color(0xFF191D19),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 128,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount = 48;
    const dashFraction = 0.55;

    for (var i = 0; i < dashCount; i++) {
      final start = (i / dashCount) * 2 * math.pi;
      final sweep = (1 / dashCount) * 2 * math.pi * dashFraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

class _DotGridPainter extends CustomPainter {
  final Color color;

  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 24.0;
    const radius = 0.75;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => old.color != color;
}
