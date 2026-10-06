import 'package:flutter/material.dart';
import '../widgets/app_brand_logo.dart';
import 'theme_colors.dart';

class ScheduledRequestsScreen extends StatefulWidget {
  const ScheduledRequestsScreen({super.key});

  @override
  State<ScheduledRequestsScreen> createState() =>
      _ScheduledRequestsScreenState();
}

class _ScheduledRequestsScreenState extends State<ScheduledRequestsScreen> {
  final List<Map<String, String>> _scheduled = [
    {
      'id': 'REQ-1042',
      'title': 'Routine Desludging',
      'address': '123 Green Street, Barangay 5',
      'date': 'Sep 25, 2026 • 9:00 AM',
      'status': 'Confirmed',
    },
    {
      'id': 'REQ-1038',
      'title': 'Septic Overflow',
      'address': '45 Eco Village, Phase 2',
      'date': 'Sep 28, 2026 • 2:00 PM',
      'status': 'Scheduled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: context.appText,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBrandLogo(size: 26),
            const SizedBox(width: 8),
            Text(
              'Scheduled Requests',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appText,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _scheduled.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 64,
                    color: context.appMutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scheduled requests yet',
                    style: TextStyle(fontSize: 16, color: context.appText),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/schedule-service');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appAccent,
                      foregroundColor: context.appOnAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Schedule a Service'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _scheduled.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _scheduled[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.appBorder.withValues(alpha: 0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF12562B).withValues(alpha: 0.06),
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
                            item['id']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.appAccent,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.appAccent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['status']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.appAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.appText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['address']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appMutedText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: context.appMutedText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['date']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.appMutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
