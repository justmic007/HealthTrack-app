import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/utils/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = AppRouter.createRouter();
          
          return MaterialApp.router(
            title: 'HealthTrack',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}