import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../services/gemini_service.dart';
import '../../providers/circle_provider.dart';
import '../../providers/pulse_provider.dart';

class ResolveScreen extends ConsumerStatefulWidget {
  const ResolveScreen({super.key});

  @override
  ConsumerState<ResolveScreen> createState() => _ResolveScreenState();
}

class _ResolveScreenState extends ConsumerState<ResolveScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _resolveGuide = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadResolveGuide();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadResolveGuide() async {
    try {
      final circle = ref.read(activeCircleProvider);
      final circleId = circle?.id ?? 'unknown';

      // Get current trust score from pulses
      double trustScore = 45.0;
      final pulsesAsync = ref.read(circlePulsesProvider);
      pulsesAsync.whenData((pulses) {
        if (pulses.isNotEmpty) {
          trustScore = pulses.map((p) => p.trustScore).reduce((a, b) => a + b) / pulses.length;
        }
      });

      final guide = await ref.read(geminiServiceProvider).generateResolveGuide(
        circleId,
        trustScore,
        [],
      );
      if (mounted) {
        setState(() {
          _resolveGuide = guide;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resolveGuide = 'Failed to generate guide: $e\n\nPlease check your internet connection and try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.risk.withValues(alpha: 0.5 + (_pulseController.value * 0.5)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Text('Resolve Mode',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.risk),
                  const SizedBox(height: 20),
                  Text(
                    'Generating conflict resolution guide...',
                    style: TextStyle(color: subColor, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.risk.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.risk.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.healing_rounded, color: AppColors.risk, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Conflict Resolution Guide',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generated by Aura based on your circle\'s trust data',
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Guide content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: MarkdownBody(
                      data: _resolveGuide,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: textColor, fontSize: 14, height: 1.7),
                        h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                        h2: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                        h3: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
                        listBullet: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Retry button
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _loadResolveGuide();
                    },
                    icon: Icon(Icons.refresh_rounded, color: subColor),
                    label: Text('Regenerate Guide', style: TextStyle(color: subColor)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Done button
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.risk,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
