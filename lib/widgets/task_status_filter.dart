import 'package:flutter/material.dart';

Future<void> showTaskStatusFilter(
  BuildContext context, {
  required String currentStatus,
}) async {
  final route = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in const [
            ('All Tasks', '/home'),
            ('Pending', '/pending-requests'),
            ('Ongoing', '/ongoing-requests'),
            ('Completed', '/request-history'),
          ])
            ListTile(
              title: Text(entry.$1),
              trailing: currentStatus == entry.$1
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(sheetContext, entry.$2),
            ),
        ],
      ),
    ),
  );

  if (route == null || !context.mounted) return;
  if (route == '/home') {
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  } else if (route != _routeFor(currentStatus)) {
    Navigator.pushReplacementNamed(context, route);
  }
}

String _routeFor(String status) => switch (status) {
  'Pending' => '/pending-requests',
  'Ongoing' => '/ongoing-requests',
  'Completed' => '/request-history',
  _ => '/home',
};
