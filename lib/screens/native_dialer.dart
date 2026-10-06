import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openNativeDialer(
  BuildContext context, {
  required String? phoneNumber,
}) async {
  final number = phoneNumber?.trim();
  var launched = false;
  try {
    launched = await launchUrl(
      Uri(scheme: 'tel', path: number ?? ''),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    launched = false;
  }
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the phone dialer.')),
    );
  } else if ((number == null || number.isEmpty) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No saved number is available; enter it in the dialer.'),
      ),
    );
  }
}
