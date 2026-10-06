import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'auth_store.dart';
import 'native_dialer.dart';
import 'theme_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<AppUser?> _currentUser = AuthStore.currentUser();

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
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildFilters(context),
            const SizedBox(height: 28),
            _buildActiveTracking(context),
            const SizedBox(height: 28),
            Text(
              "Recent Requests",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.appText,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentRequests(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            'Home',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.appAccent,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: context.appMutedText),
          tooltip: 'Messages',
          onPressed: () => Navigator.pushNamed(context, '/messages'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: FutureBuilder<AppUser?>(
            future: _currentUser,
            builder: (context, snapshot) {
              final path = snapshot.data?.profileImagePath;
              final imageFile = path == null ? null : File(path);
              final hasImage = imageFile?.existsSync() ?? false;
              return CircleAvatar(
                radius: 18,
                backgroundColor: context.appSurfaceContainer,
                backgroundImage: hasImage ? FileImage(imageFile!) : null,
                child: hasImage
                    ? null
                    : Icon(Icons.person, size: 19, color: context.appMutedText),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search requests...",
          prefixIcon: Icon(Icons.search, color: context.appMutedText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(context, "All Tasks", true, onTap: () {}),
          _filterChip(
            context,
            "Pending",
            false,
            onTap: () {
              Navigator.pushNamed(context, '/pending-requests');
            },
          ),
          _filterChip(
            context,
            "Ongoing",
            false,
            onTap: () {
              Navigator.pushNamed(context, '/ongoing-requests');
            },
          ),
          _filterChip(
            context,
            "Completed",
            false,
            onTap: () {
              Navigator.pushNamed(context, '/request-history');
            },
          ),
          _filterChip(
            context,
            "Filters",
            false,
            icon: Icons.filter_list,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    bool selected, {
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        showCheckmark: false,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? context.appOnAccent : context.appText,
              ),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        onSelected: (_) => onTap(),
        backgroundColor: context.appSurfaceContainer,
        selectedColor: context.appAccent,
        labelStyle: TextStyle(
          color: selected ? context.appOnAccent : context.appText,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildActiveTracking(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12562B).withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF243028)
                      : const Color(0xFF94F4AD),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: context.appAccent),
                    const SizedBox(width: 6),
                    Text(
                      "Live Update",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.appAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                    ),
                    SizedBox(height: 4),
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
                    style: TextStyle(fontSize: 12, color: context.appMutedText),
                  ),
                  Text(
                    "14 mins",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.appAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimeline(context),
          const SizedBox(height: 16),
          Container(
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
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Lead Technician • 4.9 ★",
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.call, color: context.appAccent),
                  onPressed: () =>
                      openNativeDialer(context, phoneNumber: null),
                ),
                IconButton(
                  icon: Icon(Icons.chat, color: context.appAccent),
                  onPressed: () {
                    Navigator.pushNamed(context, '/messages');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: context.appBorder,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const FractionallySizedBox(
            widthFactor: 0.65,
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF006D38), Color(0xFFAEF3B9)],
                ),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimelineDot(label: "Request", icon: Icons.check, active: true),
            _TimelineDot(
              label: "Assigned",
              icon: Icons.person_search,
              active: true,
            ),
            _TimelineDot(
              label: "En Route",
              icon: Icons.local_shipping,
              active: true,
            ),
            _TimelineDot(
              label: "Complete",
              icon: Icons.inventory_2,
              active: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentRequests(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _requestCard(
                context,
                "Water Quality Check",
                "Zone B - Residential Area",
                "Completed",
                Colors.teal,
                Icons.water_drop,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _requestCard(
                context,
                "Air Filtration Service",
                "Central Plaza Hub",
                "Pending",
                Colors.orange,
                Icons.cyclone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ecoAuditCard(context),
      ],
    );
  }

  Widget _requestCard(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    Color accent,
    IconData icon,
  ) {
    final isCompleted = status.toLowerCase() == "completed";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Icon(icon, color: accent, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appSurfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                color: isCompleted ? context.appAccent : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: isCompleted ? context.appAccent : Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ecoAuditCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eco-System Audit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Comprehensive survey of local biodiversity corridor.",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _smallInfoBox(context, "Status", "Ongoing"),
              const SizedBox(width: 10),
              _smallInfoBox(context, "Duration", "3 Days"),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("View Detailed Report"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoBox(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.appSurfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: context.appMutedText),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/schedule-service');
      },
      backgroundColor: context.appAccent,
      foregroundColor: context.appOnAccent,
      icon: const Icon(Icons.add),
      label: const Text("New Request"),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return const AppBottomNav(currentIndex: 0);
  }
}

class _TimelineDot extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _TimelineDot({
    required this.label,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? context.appAccent : context.appSurfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? context.appOnAccent : context.appMutedText,
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
}
