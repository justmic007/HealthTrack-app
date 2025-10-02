import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/sharing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AuthProvider and check authentication status
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SharingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}