import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/gratitude_provider.dart';
import '../../data/models/gratitude_model.dart';

class GratitudeScreen extends ConsumerStatefulWidget {
  const GratitudeScreen({super.key});

  @override
  ConsumerState<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends ConsumerState<GratitudeScreen> {
  final _messageController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _postGratitude() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) return;

    final user = ref.read(authStateProvider).asData?.value;
    final circle = ref.read(activeCircleProvider);
    final userModel = ref.read(currentUserProvider).asData?.value;
    if (user == null || circle == null) return;

    setState(() => _isPosting = true);
    try {
      await ref.read(firestoreServiceProvider).postGratitude(
            authorId: user.uid,
            authorName: userModel?.name ?? user.email ?? 'Anonymous',
            circleId: circle.id,
            message: msg,
          );
      _messageController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _react(String gratitudeId, String emoji) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    
    await ref.read(firestoreServiceProvider).addReaction(
          gratitudeId: gratitudeId,
          emoji: emoji,
          uid: user.uid,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final circle = ref.watch(activeCircleProvider);
    final feedAsync = ref.watch(gratitudeFeedProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Appreciation Wall',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          if (circle != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(circle.name,
                    style: TextStyle(
                        color: primary, fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Post composer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                  bottom: BorderSide(color: borderColor, width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Share something you appreciate...',
                      hintStyle:
                          TextStyle(color: subColor.withOpacity(0.6)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isPosting ? null : _postGratitude,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isPosting
                        ? const Center(
                            child: SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Feed
          Expanded(
            child: feedAsync.when(
              loading: () => Center(
                  child: CircularProgressIndicator(color: primary)),
              error: (e, _) => Center(
                  child: Text('Error loading feed',
                      style: TextStyle(color: textColor))),
              data: (posts) {
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volunteer_activism_rounded,
                            size: 56, color: primary),
                        const SizedBox(height: 16),
                        Text(
                          'No gratitude posts yet',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something kind!',
                          style: TextStyle(color: subColor, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (ctx, i) => _GratitudeCard(
                    post: posts[i],
                    isDark: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primary: primary,
                    onReact: _react,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  final GratitudeModel post;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final Color borderColor;
  final Color primary;
  final Future<void> Function(String, String) onReact;

  const _GratitudeCard({
    required this.post,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.borderColor,
    required this.primary,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(post.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.15),
                child: Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(timeStr,
                        style: TextStyle(color: subColor, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.favorite_rounded, color: primary, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            post.message,
            style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 14),

          // Reactions
          Row(
            children: AppConstants.reactions.map((emoji) {
              final count = post.reactions[emoji] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onReact(post.id, emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? primary.withOpacity(0.12)
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: count > 0 ? primary.withOpacity(0.4) : borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 16)),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
