import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final themeMode = ref.watch(themeModeProvider);

    final userAsync = ref.watch(currentUserProvider);
    final circlesAsync = ref.watch(userCirclesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('My Aura',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: userAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: primary)),
          error: (_, __) => Center(
              child: Text('Error loading profile',
                  style: TextStyle(color: textColor))),
          data: (user) {
            final circleCount =
                (circlesAsync.asData?.value ?? []).length;
            final name = user?.name ?? 'User';
            final email = user?.email ?? '';
            final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

            return Column(
              children: [
                // Avatar + name
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _showEditNameDialog(context, ref, user!.uid, name, bgColor, textColor, primary, subColor);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit_rounded, color: primary, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(email,
                          style: TextStyle(color: subColor, fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatBadge(
                            value: '$circleCount',
                            label: 'Circles Joined',
                            primary: primary,
                            textColor: textColor,
                            subColor: subColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings card
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      // Theme toggle
                      _SettingsTile(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        label: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                        subtitle: isDark
                            ? 'Warm & accessible for everyone'
                            : 'Dark mode for night use',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).set(
                                val ? ThemeMode.dark : ThemeMode.light);
                          },
                          activeColor: primary,
                        ),
                      ),
                      Divider(color: borderColor, height: 1),
                      Consumer(
                        builder: (context, ref, child) {
                          final notificationsEnabled = ref.watch(notificationsEnabledProvider);
                          return _SettingsTile(
                            icon: Icons.notifications_active_outlined,
                            label: 'Daily Reminders',
                            subtitle: 'Get a nudge for your Trust Pulse',
                            textColor: textColor,
                            subColor: subColor,
                            primary: primary,
                            trailing: Switch(
                              value: notificationsEnabled,
                              onChanged: (val) {
                                ref.read(notificationsEnabledProvider.notifier).toggle(val);
                              },
                              activeColor: primary,
                            ),
                          );
                        },
                      ),
                      Divider(color: borderColor, height: 1),
                      _SettingsTile(
                        icon: Icons.group_add_outlined,
                        label: 'Create a Circle',
                        subtitle: 'Start a new trusted group',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/circles/create'),
                      ),
                      Divider(color: borderColor, height: 1),
                      _SettingsTile(
                        icon: Icons.vpn_key_outlined,
                        label: 'Join a Circle',
                        subtitle: 'Enter an invite code',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/circles/join'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Professional Settings card
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Account Settings',
                        subtitle: 'Update profile and security',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/profile/settings'),
                      ),
                      Divider(color: borderColor, height: 1),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy & Security',
                        subtitle: 'Manage your data',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/profile/privacy'),
                      ),
                      Divider(color: borderColor, height: 1),
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        subtitle: 'FAQ and contact',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/profile/help'),
                      ),
                      Divider(color: borderColor, height: 1),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About TrustCircle',
                        subtitle: 'Terms and Privacy Policy',
                        textColor: textColor,
                        subColor: subColor,
                        primary: primary,
                        onTap: () => context.push('/profile/about'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Logout card
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    subtitle: 'See you next time!',
                    textColor: AppColors.risk,
                    subColor: subColor,
                    primary: AppColors.risk,
                    onTap: () async {
                      // Clear onboarding preference so new accounts see the walkthrough during demos
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('onboarding_complete');
                      
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'TrustCircle v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color primary;
  final Color textColor;
  final Color subColor;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.primary,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: primary, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: subColor, fontSize: 12)),
        ],
      ),
    );
  }
}

void _showEditNameDialog(BuildContext context, WidgetRef ref, String uid, String currentName, Color bgColor, Color textColor, Color primary, Color subColor) {
  final controller = TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Text('Edit Name', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: subColor),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: subColor.withOpacity(0.5))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: subColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                await ref.read(firestoreServiceProvider).updateUserName(uid, newName);
                ref.invalidate(currentUserProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color textColor;
  final Color subColor;
  final Color primary;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
    required this.primary,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primary, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(color: subColor, fontSize: 12)),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios_rounded,
              color: subColor, size: 14),
    );
  }
}
