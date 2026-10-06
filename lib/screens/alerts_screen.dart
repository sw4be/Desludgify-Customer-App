import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'theme_colors.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final today = [
      _AlertItem(
        icon: Icons.verified,
        iconBg: context.appAccent.withValues(alpha: 0.15),
        iconColor: context.appAccent,
        title: 'AI Image Verification Complete',
        time: 'Just Now',
        timeHighlight: true,
        body:
            'Your septic tank image verification has finished. Sludge levels analyzed and priority schedule is now available.',
        accentBar: true,
        actionLabel: 'Check Result',
        actionIcon: Icons.assignment_turned_in,
        onTap: () {
          Navigator.of(context).pushNamed('/verification-result');
        },
        onAction: () {
          Navigator.of(context).pushNamed('/verification-result');
        },
      ),
      _AlertItem(
        icon: Icons.manage_accounts,
        iconBg: context.appSurfaceContainer,
        iconColor: context.appAccent,
        title: 'Account Profile Updated',
        time: '9:15 AM',
        body:
            'Your account full name was successfully updated in your profile settings.',
      ),
      _AlertItem(
        icon: Icons.check_circle,
        iconBg: context.appAccent.withValues(alpha: 0.15),
        iconColor: context.appAccent,
        title: 'Septic Tank Desludging Completed',
        time: '8:15 AM',
        body:
            'Sipsip Eco-Truck #04 completed extraction and disposal for REQ-8821. View service receipt & digital certificate.',
      ),
    ];

    final yesterday = [
      _AlertItem(
        icon: Icons.local_shipping,
        iconBg: context.appSurfaceContainer,
        iconColor: context.appAccent,
        title: 'Scheduled Sipsip Dispatch Confirmed',
        time: '4:50 PM',
        body:
            'Your septic tank desludging appointment is set for October 28, 2025 with Team Lead Marcus Thorne.',
      ),
      _AlertItem(
        icon: Icons.shield,
        iconBg: context.appSurfaceContainer,
        iconColor: context.appMutedText,
        title: 'Password Changed',
        time: '1:30 PM',
        body:
            'The security password for your Deslugify account was recently changed. If this wasn\'t you, review security.',
        dimmed: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
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
                    Text(
                      'Alerts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appText,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list, color: context.appText),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.appAccent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF12562B,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: context.appOnAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...today.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AlertCard(item: a),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Yesterday',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...yesterday.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AlertCard(item: a),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(left: 16, right: 16, bottom: 16, child: _buildBottomNav()),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 3, overlay: true);
  }
}

class _AlertItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String time;
  final bool timeHighlight;
  final String body;
  final bool accentBar;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool dimmed;

  const _AlertItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.body,
    this.timeHighlight = false,
    this.accentBar = false,
    this.actionLabel,
    this.actionIcon,
    this.onTap,
    this.onAction,
    this.dimmed = false,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertItem item;
  const _AlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.dimmed ? 0.8 : 1,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.accentBar
                  ? context.appAccent.withValues(alpha: 0.5)
                  : context.appBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12562B).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.accentBar)
                  Container(width: 4, color: context.appAccent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.appText,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: item.timeHighlight
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: item.timeHighlight
                                          ? context.appAccent
                                          : context.appMutedText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: context.appMutedText,
                                ),
                              ),
                              if (item.actionLabel != null) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 42,
                                  child: ElevatedButton.icon(
                                    onPressed: item.onAction,
                                    icon: Icon(item.actionIcon, size: 18),
                                    label: Text(
                                      item.actionLabel!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.appAccent,
                                      foregroundColor: context.appOnAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
