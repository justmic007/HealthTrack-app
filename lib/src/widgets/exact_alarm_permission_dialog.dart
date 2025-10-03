import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExactAlarmPermissionDialog extends StatelessWidget {
  const ExactAlarmPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reminder Timing'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your reminder has been created successfully!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'However, for the most accurate reminder timing, please enable "Schedule Exact Alarms" permission in your device settings.',
          ),
          SizedBox(height: 12),
          Text(
            'Without this permission, reminders may be delayed by a few minutes.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _openAlarmSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    );
  }

  Future<void> _openAlarmSettings() async {
    try {
      // Android-specific intent to open exact alarm settings
      const url = 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // Fallback to general app settings
        const settingsUrl = 'package:com.example.temp_healthtrack';
        if (await canLaunchUrl(Uri.parse(settingsUrl))) {
          await launchUrl(Uri.parse(settingsUrl));
        }
      }
    } catch (e) {
      print('Could not open settings: $e');
    }
  }
}