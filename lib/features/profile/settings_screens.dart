import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Account Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline_rounded, size: 64, color: primary),
            const SizedBox(height: 16),
            Text('Account Settings', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Manage your profile and preferences here.', style: TextStyle(color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Privacy & Security', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.privacy_tip_outlined, size: 64, color: primary),
            const SizedBox(height: 16),
            Text('Privacy & Security', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Control your data and security settings.', style: TextStyle(color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Help & Support', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline_rounded, size: 64, color: primary),
            const SizedBox(height: 16),
            Text('Help & Support', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Find FAQs and contact our support team.', style: TextStyle(color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text('About', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: 64, color: primary),
            const SizedBox(height: 16),
            Text('TrustCircle', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: textColor.withOpacity(0.7))),
            const SizedBox(height: 16),
            Text('Built with ❤️ by Zombie Heart', style: TextStyle(color: textColor.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
