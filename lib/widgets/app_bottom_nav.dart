import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    this.overlay = false,
    super.key,
  });

  final int currentIndex;
  final bool overlay;

  static const _labels = ['Home', 'Request', 'Tasks', 'Alerts', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.add_circle_outline,
    Icons.assignment_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];
  static const _activeIcons = [
    Icons.home,
    Icons.add_circle,
    Icons.assignment,
    Icons.notifications,
    Icons.person,
  ];
  static const _routes = [
    '/home',
    '/schedule-service',
    '/request-history',
    '/alerts',
    '/profile',
  ];

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, _routes[index], (_) => false);
      return;
    }
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? const Color(0xFF94F4AD)
        : const Color(0xFF006D38);
    final inactiveColor = isDark
        ? const Color(0xFF9AA39A)
        : const Color(0xFF707970);

    return Container(
      margin: overlay
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isSelected = index == currentIndex;
          final color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: InkWell(
              onTap: () => _navigate(context, index),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? _activeIcons[index] : _icons[index],
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _labels[index],
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
