import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/gratitude_provider.dart';
import '../../services/gemini_service.dart';
import '../../services/firestore_service.dart';
import '../../data/models/insight_model.dart';

final _geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  InsightModel? _insight;
  bool _isGenerating = false;
  bool _isLoadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingInsight();
  }

  Future<void> _loadExistingInsight() async {
    final circle = ref.read(activeCircleProvider);
    if (circle == null) {
      setState(() => _isLoadingExisting = false);
      return;
    }
    final existing =
        await FirestoreService().getLatestInsight(circle.id);
    if (mounted) {
      setState(() {
        _insight = existing;
        _isLoadingExisting = false;
      });
    }
  }

  Future<void> _generateInsight() async {
    final user = ref.read(authStateProvider).asData?.value;
    final circle = ref.read(activeCircleProvider);
    if (user == null || circle == null) return;

    setState(() => _isGenerating = true);
    try {
      final pulses = await FirestoreService().getLast7DaysPulses(
        userId: user.uid,
        circleId: circle.id,
      );
      final gratitudeCount = ref.read(gratitudeCountProvider);

      final result = await ref.read(_geminiServiceProvider).generateInsight(
            circleId: circle.id,
            pulses: pulses,
            gratitudeCount: gratitudeCount,
          );

      if (result != null) {
        await FirestoreService().saveInsight(result);
        setState(() => _insight = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate insight: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return AppColors.risk;
      case 'medium':
        return AppColors.watch;
      default:
        return AppColors.excellent;
    }
  }

  IconData _riskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.tealPrimary : AppColors.warmTeal;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final circle = ref.watch(activeCircleProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('AI Insights ✨',
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
      body: _isLoadingExisting
          ? Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header illustration
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.2),
                          primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'Powered by Gemini AI',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Analyzes your 7-day pulse data, trust scores, and gratitude activity to generate personalized insights',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subColor, fontSize: 13,
                              height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateInsight,
                          icon: _isGenerating
                              ? const SizedBox(
                                  height: 16, width: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome_rounded,
                                  size: 18),
                          label: Text(
                            _isGenerating
                                ? 'Generating…'
                                : (_insight != null
                                    ? 'Regenerate Insight'
                                    : 'Generate Insight'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_insight != null) ...[
                    const SizedBox(height: 24),

                    // Conversation Starter (Today's Prompt)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.excellent.withOpacity(0.15),
                            AppColors.excellent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.excellent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💬',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                "Today's Conversation Prompt",
                                style: TextStyle(
                                    color: AppColors.excellent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${_insight!.conversationStarter}"',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Risk Level badge
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _riskColor(_insight!.riskLevel)
                              .withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: _riskColor(_insight!.riskLevel)
                                  .withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _riskIcon(_insight!.riskLevel),
                              color: _riskColor(_insight!.riskLevel),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Risk Level',
                                  style: TextStyle(
                                      color: subColor, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                _insight!.riskLevel,
                                style: TextStyle(
                                    color: _riskColor(_insight!.riskLevel),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Summary card
                    _InsightCard(
                      icon: '📊',
                      title: 'Summary',
                      content: _insight!.summary,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subColor: subColor,
                      primary: primary,
                    ),
                    const SizedBox(height: 16),

                    // Suggestion card
                    _InsightCard(
                      icon: '💡',
                      title: 'Suggestion',
                      content: _insight!.suggestion,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subColor: subColor,
                      primary: primary,
                    ),
                  ] else ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text('✨', style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            'No insights yet',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete a few daily check-ins and\ntap "Generate Insight" to get started',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subColor, fontSize: 14,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subColor;
  final Color primary;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}
