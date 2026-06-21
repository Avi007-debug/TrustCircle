import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/circles/create_circle_screen.dart';
import '../features/circles/join_circle_screen.dart';
import '../features/checkin/checkin_screen.dart';
import '../features/gratitude/gratitude_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/resolve/resolve_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/settings_screens.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/',        builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',   builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup',  builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/circles/create', builder: (_, __) => const CreateCircleScreen()),
      GoRoute(path: '/circles/join',   builder: (_, __) => const JoinCircleScreen()),
      GoRoute(path: '/checkin',   builder: (_, __) => const CheckinScreen()),
      GoRoute(path: '/gratitude', builder: (_, __) => const GratitudeScreen()),
      GoRoute(path: '/insights',  builder: (_, __) => const InsightsScreen()),
      GoRoute(path: '/resolve',   builder: (_, __) => const ResolveScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/profile/settings', builder: (_, __) => const AccountSettingsScreen()),
      GoRoute(path: '/profile/privacy', builder: (_, __) => const PrivacySecurityScreen()),
      GoRoute(path: '/profile/help', builder: (_, __) => const HelpSupportScreen()),
      GoRoute(path: '/profile/about', builder: (_, __) => const AboutScreen()),
    ],
  );
}

// Static router for use in MaterialApp.router without ref
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',        builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',   builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',  builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/circles/create', builder: (_, __) => const CreateCircleScreen()),
    GoRoute(path: '/circles/join',   builder: (_, __) => const JoinCircleScreen()),
    GoRoute(path: '/checkin',   builder: (_, __) => const CheckinScreen()),
    GoRoute(path: '/gratitude', builder: (_, __) => const GratitudeScreen()),
    GoRoute(path: '/insights',  builder: (_, __) => const InsightsScreen()),
    GoRoute(path: '/resolve',   builder: (_, __) => const ResolveScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/profile/settings', builder: (_, __) => const AccountSettingsScreen()),
    GoRoute(path: '/profile/privacy', builder: (_, __) => const PrivacySecurityScreen()),
    GoRoute(path: '/profile/help', builder: (_, __) => const HelpSupportScreen()),
    GoRoute(path: '/profile/about', builder: (_, __) => const AboutScreen()),
  ],
);
