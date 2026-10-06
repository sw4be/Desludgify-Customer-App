import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/task_status_filter.dart';
import 'native_dialer.dart';
import 'theme_colors.dart';

class OngoingRequestsScreen extends StatelessWidget {
  const OngoingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveStatus(context),
            const SizedBox(height: 18),
            _buildStatusFilters(context),
            const SizedBox(height: 24),
            _buildActiveRequestCard(context),
            const SizedBox(height: 20),
            _buildTechnicianCard(context),
            const SizedBox(height: 20),
            _buildServiceTimeline(context),
            const SizedBox(height: 28),
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Text(
            "Ongoing Requests",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appText,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Filter tasks',
          icon: Icon(Icons.tune, color: context.appText),
          onPressed: () =>
              showTaskStatusFilter(context, currentStatus: 'Ongoing'),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: context.appText),
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFBA1A1A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.appAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: context.appAccent),
          const SizedBox(width: 8),
          Text(
            "Live Tracking Active",
            style: TextStyle(
              color: context.appAccent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(
                context,
                "All",
                false,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              ),
              _chip(
                context,
                "Pending",
                false,
                onTap: () {
                  Navigator.pushNamed(context, '/pending-requests');
                },
              ),
              _chip(
                context,
                "Ongoing",
                true,
                onTap: () => showTaskStatusFilter(
                  context,
                  currentStatus: 'Ongoing',
                ),
              ),
              _chip(
                context,
                "Completed",
                false,
                onTap: () {
                  Navigator.pushNamed(context, '/request-history');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool active, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? context.appAccent : context.appSurfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: active ? context.appOnAccent : context.appText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRequestCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#DSG-882910",
                      style: TextStyle(
                        color: context.appMutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Industrial Waste Collection",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "En Route",
                  style: TextStyle(
                    color: context.appAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _infoBox(context, "Arrival Estimate", "12 mins")),
              Expanded(child: _infoBox(context, "Volume", "4.5 Tons")),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCkPTFuhtKtZQ_SNRPjZIgazb4hrPZaOJ_ooiNqILpsh8A_WmdU6dZ656I-P5UNjwjuNvc7y_GtlPuWhePGUsldN4qG1sqp6ZEIvM7EeoiYHYZBYWeCU-D8T08nI_6gzo2eriuYCpMdGslZZJiN2ZiXV_MTnCxK0ZKzlUoJZM4-FHzr4cDaaFxqxDMFskeB6mm65OC19NstwLuYgJoPMrR4zbmWq1RQe459ZxYIvynYVYRWn2BB-DhXjhdCjcES1ke4rcvgHD4RBVlj',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: context.appSurfaceContainer,
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 40,
                        color: context.appMutedText,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 38,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.appMutedText),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.appText,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAOrLFbOnGpA-jGS4VRwUBqgyz2KgdNGcOxZ8bzsUEaT_vcUKoJ7eV6seW_vmP2KfM6iaxbW4A5nr83sIfxahZ10cZTEVZ2flP0Jvzx9QQTH0uwL_PpolbK8S4sgt4D91zkyZmgXr0zhTSiNeDNT3ttz82DyMMYWPwHUsqYY9zjTRS37SPldCFPTfdkPpB6J5-qtbDWO-zd1adUz1zqUzA2rLjmVgHo0PKy7pPPSUd87MEod9yPkgU7IyYhlgTCaPTbzGI1nbT19uMU',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 54,
                height: 54,
                color: context.appSurfaceContainer,
                child: Icon(Icons.person, color: context.appAccent),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Marcus Chen",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Lead Technician",
                  style: TextStyle(color: context.appMutedText, fontSize: 13),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFF7BDA96), size: 16),
                    Text(
                      " 4.9 ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "(240+ jobs)",
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.call, color: context.appAccent),
            onPressed: () => openNativeDialer(context, phoneNumber: null),
          ),
          IconButton(
            icon: Icon(Icons.chat, color: context.appAccent),
            onPressed: () {
              Navigator.pushNamed(context, '/messages');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTimeline(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Service Timeline",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 20),
          _timelineStep(
            context,
            "Request Submitted",
            "09:00 AM • Verified",
            true,
          ),
          _timelineStep(context, "Team Assigned", "09:15 AM • Marcus C.", true),
          _timelineStep(
            context,
            "En Route",
            "Estimated arrival 12:42 PM",
            true,
            isActive: true,
          ),
          _timelineStep(
            context,
            "Ongoing Service",
            "Waiting for arrival",
            false,
          ),
          _timelineStep(context, "Completed", "", false, isLast: true),
        ],
      ),
    );
  }

  Widget _timelineStep(
    BuildContext context,
    String title,
    String subtitle,
    bool completed, {
    bool isActive = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isActive
                    ? context.appAccent
                    : completed
                    ? const Color(0xFF94F4AD)
                    : context.appSurfaceContainer,
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 14,
                    )
                  : completed
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: completed
                    ? context.appAccent.withValues(alpha: 0.55)
                    : context.appBorder,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? context.appAccent : context.appText,
                    fontSize: 14,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.appMutedText),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/live-tracking');
            },
            icon: const Icon(Icons.map, size: 20),
            label: const Text(
              'Track Live',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appAccent,
              foregroundColor: context.appOnAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Cancel request?'),
                content: const Text(
                  'Contact support to cancel an ongoing service request.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushNamed(context, '/messages');
                    },
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appAccent,
              side: BorderSide(color: context.appBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel Request',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 2);
  }
}
