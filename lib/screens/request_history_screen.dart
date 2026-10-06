import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/task_status_filter.dart';
import 'theme_colors.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key});

  Future<void> _saveReport(
    BuildContext context, {
    required String id,
    required String title,
    required String date,
    required String status,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$id-report.txt');
      await file.writeAsString(
        'Service Report\n$id\n$title\nDate: $date\nStatus: $status\n',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report saved to ${file.path}')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the service report.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF08090A) : const Color(0xFFF8FAF3);
    final card = isDark ? const Color(0xFF17181C) : Colors.white;
    final text = isDark ? const Color(0xFFF5F6F7) : const Color(0xFF003D1A);
    final muted = isDark ? const Color(0xFFB0B4BC) : const Color(0xFF707970);
    final border = isDark ? const Color(0xFF3A3D44) : const Color(0xFFE8EBE6);
    final accent = isDark ? const Color(0xFFE8EAED) : const Color(0xFF006D38);
    final chipBg = isDark ? const Color(0xFF202126) : const Color(0xFFECEFE8);
    final chipInactive = isDark
        ? const Color(0xFF202126)
        : const Color(0xFFE6E9E2);
    final infoBox = isDark ? const Color(0xFF202126) : const Color(0xFFF2F5EE);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context, isDark, accent, text),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(card, border, text, muted),
            const SizedBox(height: 28),
            _buildFilters(context, chipBg, chipInactive, text),
            const SizedBox(height: 24),
            Text(
              "Request History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              context: context,
              icon: Icons.cleaning_services,
              iconColor: accent,
              title: "Eco-Industrial Desludging",
              id: "#DSL-99201",
              date: "Oct 24, 2023",
              status: "COMPLETED",
              statusColor: accent,
              technician: "Marcus Thorne",
              technicianRole: "Lead Technician • 4.9★",
              duration: "2h 45m",
              volume: "450 Liters",
              rating: 5,
              card: card,
              border: border,
              text: text,
              muted: muted,
              infoBox: infoBox,
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              context: context,
              icon: Icons.block,
              iconColor: const Color(0xFFBA1A1A),
              title: "Emergency Pipe Check",
              id: "#DSL-98105",
              date: "Oct 12, 2023",
              status: "CANCELLED",
              statusColor: const Color(0xFFBA1A1A),
              technician: null,
              isCancelled: true,
              card: card,
              border: border,
              text: text,
              muted: muted,
              infoBox: infoBox,
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              context: context,
              icon: Icons.history,
              iconColor: muted,
              title: "Routine Tank Drainage",
              id: "#DSL-97554",
              date: "Sep 28, 2023",
              status: "COMPLETED",
              statusColor: accent,
              technician: "Sarah Jenkins",
              technicianRole: "Senior Field Expert • 5.0★",
              duration: "1h 15m",
              rating: 4,
              card: card,
              border: border,
              text: text,
              muted: muted,
              infoBox: infoBox,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    Color accent,
    Color text,
  ) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A211C) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? accent : const Color(0xFF003D1A),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Text(
            "Tasks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? accent : const Color(0xFF003D1A),
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Filter tasks',
          icon: Icon(
            Icons.tune,
            color: isDark ? accent : const Color(0xFF003D1A),
          ),
          onPressed: () =>
              showTaskStatusFilter(context, currentStatus: 'Completed'),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(
    Color card,
    Color border,
    Color text,
    Color muted,
  ) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "COMPLETED",
            "24",
            Icons.check_circle,
            const Color(0xFF006D38),
            card,
            border,
            text,
            muted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            "CANCELLED",
            "2",
            Icons.cancel,
            const Color(0xFFBA1A1A),
            card,
            border,
            text,
            muted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _impactCard()),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color card,
    Color border,
    Color text,
    Color muted,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              Icon(icon, color: color, size: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12562B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("IMPACT", style: TextStyle(fontSize: 11, color: Colors.white70)),
          SizedBox(height: 8),
          Text(
            "120 kg",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            "CO₂ offset",
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    Color chipBg,
    Color chipInactive,
    Color text,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  "All Requests",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: text,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.expand_more, size: 18, color: text),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _filterChip(context, "This Year", true, chipInactive, text),
          const SizedBox(width: 8),
          _filterChip(context, "Sort by Date", false, chipInactive, text),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    bool active,
    Color chipInactive,
    Color text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? context.appAccent : chipInactive,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: active ? context.appOnAccent : text,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String id,
    required String date,
    required String status,
    required Color statusColor,
    String? technician,
    String? technicianRole,
    String? duration,
    String? volume,
    int? rating,
    bool isCancelled = false,
    required Color card,
    required Color border,
    required Color text,
    required Color muted,
    required Color infoBox,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withValues(alpha: 0.12),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isCancelled)
              Container(
                width: 2,
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
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
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$id • $date",
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (technician != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: muted.withValues(alpha: 0.2),
                        child: Icon(Icons.person, size: 18, color: muted),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            technician,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: text,
                            ),
                          ),
                          Text(
                            technicianRole ?? "",
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                if (duration != null || volume != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (duration != null)
                        Expanded(
                          child: _infoBox(
                            "Duration",
                            duration,
                            infoBox,
                            text,
                            muted,
                          ),
                        ),
                      if (volume != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoBox(
                            "Volume",
                            volume,
                            infoBox,
                            text,
                            muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: const Color(0xFF7BDA96),
                        size: 18,
                      ),
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
                            title: const Text('Service Report'),
                            content: Text(
                              '$title\n$id\nDate: $date\nStatus: $status',
                            ),
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
                          "View Report",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _saveReport(
                          context,
                          id: id,
                          title: title,
                          date: date,
                          status: status,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appAccent,
                          side: BorderSide(color: context.appBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Download",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          color: context.appAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBox(
    String label,
    String value,
    Color infoBox,
    Color text,
    Color muted,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: infoBox,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 2);
  }
}
