import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'theme_colors.dart';
import 'native_dialer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            // Search & Filters
            _buildSearchAndFilters(context),
            const SizedBox(height: 28),

            // Active Tracking
            _buildActiveTracking(context),
            const SizedBox(height: 28),

            // Recent Requests
            _buildRecentRequests(context),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
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
            'Deslugify',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.appText,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: context.appText),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 14),
          child: CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBrDiNizbkcLGMD2f2zerqt9KeqijC4Z5uPmaI3akKXHo1L3mhjtJQNxQx6FuJabXSYftmYP7Ot0S7TGd8toLFBX1v0SKqptmHnhpP02VrLpCrb183IiWWJQgnS9aNNV7IdykThpiXVVLIWUXrns-k4fOIJmI0zTE1MVnM2XNk9FTHpBM-KJYgyYaNYjN6H878RGtACQ7ZzLeJqFldbFqVMWaB0zgADGxlzkz0dqhk4qWTz7pwImqbrDmS7jAoNosfc8F-0J0T-2ll6',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appBorder),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search requests...",
              hintStyle: TextStyle(color: context.appMutedText),
              prefixIcon: Icon(Icons.search, color: context.appMutedText),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip(context, "All Tasks", true),
              _filterChip(context, "Pending", false),
              _filterChip(context, "Ongoing", false),
              _filterChip(context, "Completed", false),
              _filterChip(context, "Filters", false, icon: Icons.filter_list),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    bool active, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        showCheckmark: false,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: active ? context.appOnAccent : context.appText,
              ),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        onSelected: (_) {},
        backgroundColor: context.appSurfaceContainer,
        selectedColor: context.appAccent,
        labelStyle: TextStyle(
          color: active ? context.appOnAccent : context.appText,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildActiveTracking(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active Tracking",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: context.appAccent),
                    SizedBox(width: 6),
                    Text(
                      "Live Update",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.appAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#REQ-4829",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Industrial Waste Collection - Sector 7",
                      style: TextStyle(
                        color: context.appMutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Estimated Arrival",
                    style: TextStyle(fontSize: 11, color: context.appMutedText),
                  ),
                  Text(
                    "14 mins",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.appAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimeline(context),
          const SizedBox(height: 18),
          _buildTechnicianInfo(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _timelineDot(context, "Request", Icons.check, true),
        _timelineDot(context, "Assigned", Icons.person_search, true),
        _timelineDot(context, "En Route", Icons.local_shipping, true),
        _timelineDot(context, "Complete", Icons.inventory_2, false),
      ],
    );
  }

  Widget _timelineDot(
    BuildContext context,
    String label,
    IconData icon,
    bool active,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: active
              ? context.appAccent
              : context.appSurfaceContainer,
          child: Icon(
            icon,
            color: active ? context.appOnAccent : context.appMutedText,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? context.appText : context.appMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuC3DSUpM2JGGU4UvkCgm8LM4LL96F03hSGhOWWUOlrsDPE7BrDjHQ5Y8YpbehWP14-bEntMaN02cVUJJUQktARUGU16KSuowY0BQO3wMBtfr8QftLrwMiP9Aus_ShPhVC-Rnvuzc02-Cw4sQyLT4SX8KefpL7WG1IJYG03--LTycCCiCKtjYK8JqGVApHMlPZ2sJUzRucJKRZ_7knYv198lcAUzc2bMOnlukb6-0dniu6YDmmdcZVuNMx4doZ8PkKw_lnzA7q7UubeY",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Marcus Chen",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Lead Technician • 4.9 ★",
                  style: TextStyle(fontSize: 12, color: context.appMutedText),
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
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Requests",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.appText,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _requestCard(
                context,
                "Water Quality Check",
                "Zone B",
                "Completed",
                const Color(0xFF006D38),
                Icons.water_drop,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _requestCard(
                context,
                "Air Filtration Service",
                "Central Plaza",
                "Pending",
                Colors.orange,
                Icons.cyclone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _requestCard(
    BuildContext context,
    String title,
    String location,
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            location,
            style: TextStyle(color: context.appMutedText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: context.appAccent,
      foregroundColor: context.appOnAccent,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 0);
  }
}
