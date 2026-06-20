import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrustCircleApp(),
    ),
  );
}

class TrustCircleApp extends StatelessWidget {
  const TrustCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TrustCircle',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}