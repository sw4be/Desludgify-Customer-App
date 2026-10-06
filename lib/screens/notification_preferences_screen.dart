import 'package:flutter/material.dart';
import '../widgets/app_brand_logo.dart';
import 'theme_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _serviceUpdates = true;
  bool _technicianArrival = true;
  bool _chatMessages = true;
  bool _scheduledReminders = true;
  bool _promotions = false;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const AppBrandLogo(size: 26),
            const SizedBox(width: 8),
            Text(
              'Notification Preferences',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.appText,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what alerts you want to receive from Deslugify.',
              style: TextStyle(
                fontSize: 14,
                color: context.appMutedText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Service alerts
            _sectionTitle('Service Alerts'),
            const SizedBox(height: 10),
            _card(
              children: [
                _switchTile(
                  title: 'Service status updates',
                  subtitle: 'Assigned, en route, completed',
                  value: _serviceUpdates,
                  onChanged: (v) => setState(() => _serviceUpdates = v),
                ),
                _divider(),
                _switchTile(
                  title: 'Technician arrival alerts',
                  subtitle: 'Notify when technician is nearby',
                  value: _technicianArrival,
                  onChanged: (v) => setState(() => _technicianArrival = v),
                ),
                _divider(),
                _switchTile(
                  title: 'Scheduled reminders',
                  subtitle: 'Reminders before your appointment',
                  value: _scheduledReminders,
                  onChanged: (v) => setState(() => _scheduledReminders = v),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Messages
            _sectionTitle('Messages'),
            const SizedBox(height: 10),
            _card(
              children: [
                _switchTile(
                  title: 'Chat messages',
                  subtitle: 'Messages from technician or support',
                  value: _chatMessages,
                  onChanged: (v) => setState(() => _chatMessages = v),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Other
            _sectionTitle('Other'),
            const SizedBox(height: 10),
            _card(
              children: [
                _switchTile(
                  title: 'Promotions & tips',
                  subtitle: 'Eco tips, offers, and news',
                  value: _promotions,
                  onChanged: (v) => setState(() => _promotions = v),
                ),
                _divider(),
                _switchTile(
                  title: 'Email notifications',
                  subtitle: 'Receive the same updates by email',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification preferences saved'),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appAccent,
                  foregroundColor: context.appOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.appText,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.appText,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: context.appMutedText),
      ),
      value: value,
      activeThumbColor: context.appAccent,
      activeTrackColor: context.appAccent.withValues(alpha: 0.35),
      onChanged: onChanged,
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 16, endIndent: 16, color: context.appBorder);
}
