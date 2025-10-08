import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/sharing_provider.dart';
import 'src/providers/reminder_provider.dart';
import 'src/services/platform_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-aware notification service
  await PlatformNotificationService().initialize();
  
  // Initialize AuthProvider and check authentication status
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SharingProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}