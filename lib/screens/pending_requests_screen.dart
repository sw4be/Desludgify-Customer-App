import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/task_status_filter.dart';
import 'theme_colors.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

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
            _buildFilterChips(context),
            const SizedBox(height: 24),
            _buildRequestCard(
              context: context,
              id: "DSL-82910",
              title: "Septic Inspection",
              date: "Oct 24, 2023",
              estimate: "Est. 2-3 Days",
              urgency: "HIGH",
              description:
                  "Periodic maintenance inspection for residential sludge filtration system in Sector 4.",
              location: "Silver Creek, S4",
            ),
            const SizedBox(height: 14),
            _buildRequestCard(
              context: context,
              id: "DSL-82944",
              title: "Filter Replacement",
              date: "Oct 26, 2023",
              estimate: "Est. 12 Hours",
              urgency: "LOW",
              description:
                  "Carbon filter replacement for the main kitchen drainage outlet. Sensor reports 85% capacity.",
            ),
            const SizedBox(height: 14),
            _buildRequestCard(
              context: context,
              id: "DSL-83002",
              title: "System Diagnostic",
              date: "Oct 28, 2023",
              estimate: "Est. 24 Hours",
              urgency: "MEDIUM",
              description:
                  "Comprehensive system health check for main treatment unit.",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/schedule-service');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
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
            'Pending Requests',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appText,
              fontSize: 18,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.appText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: 'Filter tasks',
          icon: Icon(Icons.tune, color: context.appText),
          onPressed: () =>
              showTaskStatusFilter(context, currentStatus: 'Pending'),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
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
            true,
            onTap: () =>
                showTaskStatusFilter(context, currentStatus: 'Pending'),
          ),
          _chip(
            context,
            "Ongoing",
            false,
            onTap: () {
              Navigator.pushNamed(context, '/ongoing-requests');
            },
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

  Widget _buildRequestCard({
    required BuildContext context,
    required String id,
    required String title,
    required String date,
    required String estimate,
    required String urgency,
    required String description,
    String? location,
  }) {
    Color urgencyBg;
    Color urgencyText;

    switch (urgency) {
      case "HIGH":
        urgencyBg = context.appErrorContainer;
        urgencyText = context.appError;
        break;
      case "MEDIUM":
        urgencyBg = context.appAccent.withValues(alpha: 0.15);
        urgencyText = context.appAccent;
        break;
      default:
        urgencyBg = context.appSurfaceContainer;
        urgencyText = context.appAccent;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                      id,
                      style: TextStyle(
                        color: context.appMutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: context.appText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      urgency,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: urgencyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.appAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "PENDING",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.appAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: context.appAccent),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: context.appText),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 16, color: context.appAccent),
              const SizedBox(width: 6),
              Text(
                estimate,
                style: TextStyle(fontSize: 14, color: context.appText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: context.appMutedText,
              height: 1.45,
              fontSize: 14,
            ),
          ),
          if (location != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBfewjABXMc18FBaw_koz5I5cAtOSUATKgueBOVSFgcTjSPW2oSg8fc7eFmf--a6QOfGsHtPCAioXMiPd78oMIxnw9-98b0jO1XoxXDYrgKOaDnQVrZDZx-FtZE7AF8g2CbsAppneiV6AI-LMudiWsAAw8L61NXFllsuW03a_m2Yx5_dI7B5XJK0CH4NZfI9rTmGEUhZEvkuDhcHfW22tNMPI1TbaU9X5ngic25I7Y10CnSJy6AtMWLGmEyXhE_zTh5T-DqUJXb8Nd9',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 100,
                      color: context.appSurfaceContainer,
                      child: Center(
                        child: Icon(Icons.map, color: context.appMutedText),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.appSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: context.appAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.appText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(title),
                      content: Text('$id\n$date\n\n$description'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appAccent,
                    foregroundColor: context.appOnAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/schedule-service'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appAccent,
                    side: BorderSide(color: context.appBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Edit Request",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          if (urgency == "HIGH") ...[
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Cancel request?'),
                    content: Text('Cancel $id: $title?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Keep Request'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cancellation submitted for $id.'),
                            ),
                          );
                        },
                        child: const Text('Cancel Request'),
                      ),
                    ],
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: context.appError),
                child: const Text(
                  "Cancel Request",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 2);
  }
}
