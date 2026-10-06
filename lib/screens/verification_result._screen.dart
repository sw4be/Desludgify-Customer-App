import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_brand_logo.dart';
import 'theme_colors.dart';

class VerificationResultScreen extends StatefulWidget {
  const VerificationResultScreen({super.key});

  @override
  State<VerificationResultScreen> createState() =>
      _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  int _selectedDay = 28; // Oct 28 selected

  // Sample calendar: days shown in the grid (from HTML mock)
  // 25,26 muted | 27 struck | 28 selected | 29,30 priority | 31 + Nov 1-7 normal
  final List<_CalDay> _days = const [
    _CalDay(25, muted: true),
    _CalDay(26, muted: true),
    _CalDay(27, muted: true, struck: true),
    _CalDay(28, priority: true),
    _CalDay(29, priority: true),
    _CalDay(30, priority: true),
    _CalDay(31),
    _CalDay(1),
    _CalDay(2),
    _CalDay(3),
    _CalDay(4),
    _CalDay(5),
    _CalDay(6),
    _CalDay(7),
  ];

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
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const AppBrandLogo(size: 28),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deslugify',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.appText,
                            height: 1.1,
                          ),
                        ),
                        Row(
                          children: [
                            _PulseDot(),
                            SizedBox(width: 4),
                            Text(
                              'ECO-TECH INTELLIGENCE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: context.appAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.support_agent, color: context.appText),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(
                        0xFF12562B,
                      ).withValues(alpha: 0.15),
                      backgroundImage: const NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBRpRMAtGTK4959lO14Bm3D71HwWXfZF_4Rxj9Jevs9HImjGRRSzFvfRP-SNBMElxMdgXSqkcZxCS8FCPsBQv2sz9v1KvOKD4vceP9xIMH0nK1Y5d9b1q4TD2Saty2jGqH35kCOp4QOHCYmXUpyhqeEOqA9_PO5WKk6sqA9otNyKZ2tm6YdQ8BvEZcCRKVr11a1DiZg4J7xYzwspPWYrONU6_MOjFyFAIUHsQP0y525GUJ5ISK8tr4rzw',
                      ),
                      onBackgroundImageError: (_, _) {},
                      child: const Icon(Icons.person, size: 18),
                    ),
                  ),
                ],
              ),

              // ── Body ───────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Status banner
                    _buildStatusBanner(),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Verification Result & Priority Calendar',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Customer Service priority schedule authorized for your septic tank desludging request.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: context.appMutedText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Verification summary card
                    _buildVerificationCard(),
                    const SizedBox(height: 16),

                    // Calendar + dispatch
                    _buildCalendarSection(),
                    const SizedBox(height: 16),

                    // Summary + CTAs
                    _buildSummarySection(),
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

  // ── Widgets ────────────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12562B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const _PulseDot(size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Verification Complete • CS Approved',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: context.appText,
              ),
            ),
          ),
          Text(
            'Ref #DSG-89210-VERIF',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.appMutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _chip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Priority Level: High / Urgent',
                          bg: const Color(0xFF7A343F),
                          fg: Colors.white,
                        ),
                        _chip(
                          icon: Icons.verified,
                          label: 'Verified Real Photos',
                          bg: const Color(0xFF94F4AD),
                          fg: context.appOnLightAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sludge Level: 82% (Full Tank / High Overflow Risk)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text(
                    '82%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.isDarkMode
                          ? const Color(0xFFFFB4AB)
                          : const Color(0xFFBA1A1A),
                    ),
                  ),
                  Text(
                    'SLUDGE LOAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.appMutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: context.appBorder, height: 1),
          const SizedBox(height: 12),

          // Confidence bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: context.appAccent,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Verified Real Photos • 98.4% Confidence (No AI synthesis/reuse)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.appMutedText,
                        ),
                      ),
                    ),
                    Text(
                      '98.4%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.984,
                    minHeight: 8,
                    backgroundColor: context.appBorder,
                    valueColor: AlwaysStoppedAnimation(context.appAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Photos header
          Row(
            children: [
              Icon(Icons.photo_camera, size: 16, color: context.appAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Submitted Photos (3 Verified)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.appMutedText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appAccent,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: context.appAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Photo grid
          Row(
            children: [
              Expanded(
                child: _photoThumb(
                  url:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuATH69abA95C5TZfkRFyun2EOGbDkDmfu__l2bOBeatUw5Upj8hXlvNgFmOGw4qLtf9tf7a8ObAu_LoOk-OSFQrTtiFvXKjabR1xg_QQdEdlMuSrtD69mNWF4KY0KdOoAuBQ4D2HJaurssIKDK6gRbKPLWtKsKP_kqepcitLsriUFOLTX0C8hzLhFHym98R82O-ZpNpKFTGuvcX0VHjbBLscjZsJM4AOXEfBQGOxUqLkpupmsVIheWaVw',
                  label: 'Tank Opening',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _photoThumb(
                  url:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBeyNNuHfW1EzacAmWQJ3M-HjXGEhtqeTzO-js-NXapEnCKx4yBWJE9_Jkn6znfSr7so257u-9c7O9ruB4tYTivIJ8s2z_c_SmlJXY-IqQc1HARiJMSjVaKnyrIczmMkypyapdN4qGb4-v7OgVikb44fvqR8cjmRkkXaLJanWRy2eMPw0rVa8IZpygmztfB0hje3Jj-ITvCJwBBptinGGChLwN_bdeBmrtFanFdUU2UXijIZf2xqUtocg',
                  label: 'Primary Chamber',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _photoPlaceholder(
                  icon: Icons.plumbing,
                  label: 'Pipe Joint',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: context.appAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Select Authorized Service Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dates assigned by Customer Service based on priority level and sector truck availability.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: context.appMutedText,
            ),
          ),
          const SizedBox(height: 14),

          // Calendar widget
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appBorder),
            ),
            child: Column(
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'October / November 2025',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                      ),
                    ),
                    Row(
                      children: [
                        _iconBtn(Icons.chevron_left, () {}),
                        _iconBtn(Icons.chevron_right, () {}),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),
                // Day names
                Row(
                  children: ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
                      .map(
                        (d) => Expanded(
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: context.appMutedText,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                // Days grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: _days.length,
                  itemBuilder: (context, i) {
                    final day = _days[i];
                    final selected = day.day == _selectedDay;
                    return GestureDetector(
                      onTap: day.muted || day.struck
                          ? null
                          : () => setState(() => _selectedDay = day.day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: selected
                              ? context.appAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF94F4AD,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 0,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected || day.priority
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                decoration: day.struck
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: selected
                                    ? context.appOnAccent
                                    : day.muted
                                    ? context.appMutedText.withValues(
                                        alpha: 0.55,
                                      )
                                    : context.appText,
                              ),
                            ),
                            if (day.priority && !day.muted)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF94F4AD)
                                      : context.appAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(context.appAccent, 'Priority Expedited Slot'),
                    const SizedBox(width: 16),
                    _legendDot(context.appAccent, 'Selected Date', ring: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Assigned operator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF94F4AD),
                      width: 2,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBdtwTi7zN4wQUy3S9-ewDptZYwlaM7Mw7JBKS4baI03nBBTF2Z5gCfpwjqsv_VcpDKaBPYCGmh1JT_8xq7WeWdkvLceXgIBSdKMeMX5C8KBFfefJK52a7KhAg2bFc3prbqIixYZvLWAp4kQSdhEVvunMl1xpXe-aXEHDaxcTxWZglhHNz9H4PkLER1WDwSb7r0fpsZmZqweK2b7ZJIeXshCu27h9o5TMG0FT19bJITHOBzDWLylBBgQw',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.appMutedText,
                        ),
                      ),
                      Text(
                        'Team Lead Marcus Thorne',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.appText,
                        ),
                      ),
                      Text(
                        'Sipsip Eco-Truck #04 • Heavy Sludge Suction Tanker',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.appAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.bolt, color: context.appAccent, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.appSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_available, color: context.appAccent, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Service:',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.appMutedText,
                        ),
                      ),
                      Text(
                        'Septic Tank Desludging',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.appText,
                        ),
                      ),
                      Text(
                        'Tuesday, October 28, 2025 • Priority Authorized Dispatch',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Confirm
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: confirm request → navigate
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request confirmed!')),
                );
              },
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text(
                'Confirm Request',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appAccent,
                foregroundColor: context.appOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF12562B).withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Contact CS
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/messages');
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text(
                'Contact Customer Service',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appAccent,
                side: BorderSide(color: context.appBorder),
                backgroundColor: context.appSurfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 1, overlay: true);
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _chip({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoThumb({required String url, required String label}) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: context.appSurfaceContainer,
                child: Icon(Icons.image, color: context.appMutedText),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF006D38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder({required IconData icon, required String label}) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.appBorder),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: context.appText),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: context.appText,
                    ),
                  ),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: context.appAccent,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF006D38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 18, color: context.appText),
      ),
    );
  }

  Widget _legendDot(Color color, String label, {bool ring = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: ring
                ? Border.all(color: const Color(0xFF94F4AD), width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.appMutedText),
        ),
      ],
    );
  }
}

// ── Small helpers ────────────────────────────────────────────────────────

class _CalDay {
  final int day;
  final bool muted;
  final bool struck;
  final bool priority;

  const _CalDay(
    this.day, {
    this.muted = false,
    this.struck = false,
    this.priority = false,
  });
}

class _PulseDot extends StatefulWidget {
  final double size;
  const _PulseDot({this.size = 6});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: context.appAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF94F4AD).withValues(alpha: (1 - t) * 0.7),
                blurRadius: 0,
                spreadRadius: t * 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
