import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/pulse_provider.dart';
import '../../services/voice_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/gemini_service.dart';
import '../../services/ai_router_service.dart';
import '../../services/notification_service.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, double> _values = {
    'heard': 5.0,
    'respected': 5.0,
    'safe': 5.0,
    'connected': 5.0,
  };
  bool _isSubmitting = false;
  bool _useLocalAi = false;
  late AnimationController _successController;
  late Animation<double> _successAnimation;
  bool _showSuccess = false;
  
  bool _isListening = false;
  String _voiceTranscript = '';

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successAnimation = CurvedAnimation(
        parent: _successController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  String _labelForValue(double v) {
    if (v >= 8.5) return 'Great';
    if (v >= 6.5) return 'Good';
    if (v >= 4.5) return 'Okay';
    if (v >= 2.5) return 'Low';
    return 'Poor';
  }

  Color _colorForValue(double v) {
    if (v >= 8) return AppColors.excellent;
    if (v >= 6) return AppColors.healthy;
    if (v >= 4) return AppColors.watch;
    return AppColors.risk;
  }

  double get _trustScore {
    final sum = _values.values.reduce((a, b) => a + b);
    return (sum / 4.0) * 10;
  }

  Future<void> _submitPulse() async {
    final user = ref.read(authStateProvider).asData?.value;
    final circle = ref.read(activeCircleProvider);
    if (user == null || circle == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(firestoreServiceProvider).submitPulse(
            userId: user.uid,
            circleId: circle.id,
            heard: _values['heard']!,
            respected: _values['respected']!,
            safe: _values['safe']!,
            connected: _values['connected']!,
          );
      ref.invalidate(hasPulsedTodayProvider);
      ref.invalidate(weeklyPulsesProvider);
      ref.invalidate(circlePulsesProvider);

      // Cancel hourly nudge notifications since pulse was submitted
      await notificationService.cancelHourlyNudges();
      
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = !connectivityResult.contains(ConnectivityResult.none) && connectivityResult.isNotEmpty;
      
      if (!isOnline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved locally. Your pulse will sync automatically when back online!')),
        );
      }

      setState(() => _showSuccess = true);
      _successController.forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _toggleVoiceCheckin() async {
    if (_isListening) {
      await voiceService.stopListening();
      setState(() => _isListening = false);
      
      if (_voiceTranscript.isNotEmpty) {
        setState(() => _isSubmitting = true);
        try {
          final result = await ref.read(aiRouterServiceProvider).analyzeVoiceJournal(_voiceTranscript, forceLocal: _useLocalAi);
          setState(() {
            _values['heard'] = result['heard'] ?? 5.0;
            _values['respected'] = result['respected'] ?? 5.0;
            _values['safe'] = result['safe'] ?? 5.0;
            _values['connected'] = result['connected'] ?? 5.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scores updated from voice analysis!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
        } finally {
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      setState(() {
        _isListening = true;
        _voiceTranscript = '';
      });
      await voiceService.startListening((text) {
        setState(() => _voiceTranscript = text);
      });
    }
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

    final hasPulsedAsync = ref.watch(hasPulsedTodayProvider);
    final circle = ref.watch(activeCircleProvider);

    if (_showSuccess) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: ScaleTransition(
            scale: _successAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.excellent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.excellent, size: 52),
                ),
                const SizedBox(height: 24),
                Text('Pulse Submitted',
                    style: TextStyle(color: textColor, fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Your trust score: ${_trustScore.toStringAsFixed(0)}%',
                    style: TextStyle(color: primary, fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Keep checking in daily for stronger bonds.',
                    style: TextStyle(color: subColor, fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    return hasPulsedAsync.when(
      loading: () => Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primary)),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: bgColor,
        body: Center(
            child: Text('Error loading pulse status',
                style: TextStyle(color: textColor))),
      ),
      data: (hasPulsed) {
        if (hasPulsed) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: bgColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textColor, size: 20),
                onPressed: () => context.pop(),
              ),
              title: Text('Daily Trust Pulse',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_rounded,
                          color: primary, size: 52),
                    ),
                    const SizedBox(height: 24),
                    Text('Already Checked In Today',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      'Come back tomorrow to submit your next Trust Pulse.\nConsistency builds trust.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subColor, fontSize: 14,
                          height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: textColor, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text('Daily Trust Pulse',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            actions: [
              if (circle != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.25),
                        primary.withOpacity(0.08)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How are you feeling?',
                                style: TextStyle(color: textColor, fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Rate your experience today in this circle',
                                style: TextStyle(color: subColor, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _toggleVoiceCheckin,
                        icon: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
                        color: _isListening ? AppColors.risk : primary,
                        iconSize: 32,
                        tooltip: 'Voice Check-In',
                      ),
                    ],
                  ),
                ),
                if (_isListening || _voiceTranscript.isNotEmpty) ...[
                   const SizedBox(height: 12),
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                     child: Text(
                       _isListening ? 'Listening... $_voiceTranscript' : 'Voice Transcript: $_voiceTranscript',
                       style: TextStyle(color: textColor, fontSize: 13, fontStyle: FontStyle.italic),
                     ),
                   ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Use On-Device AI (TinyLlama) for Privacy', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Analyzes locally without sending audio text to the cloud', style: TextStyle(color: subColor, fontSize: 12)),
                  value: _useLocalAi,
                  activeColor: primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _useLocalAi = val),
                ),
                const SizedBox(height: 24),

                // Sliders
                ...AppConstants.pulseQuestions.map((q) {
                  final key = q['key']!;
                  final value = _values[key]!;
                  final color = _colorForValue(value);
                  return _PulseSliderCard(
                    key: ValueKey(key),
                    question: q['question']!,
                    emoji: q['emoji']!,
                    valueLabel: _labelForValue(value),
                    value: value,
                    color: color,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subColor: subColor,
                    onChanged: (v) => setState(() => _values[key] = v),
                  );
                }),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPulse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: primary.withOpacity(0.4),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Submit Trust Pulse',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulseSliderCard extends StatelessWidget {
  final String question;
  final String emoji;
  final String valueLabel;
  final double value;
  final Color color;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subColor;
  final ValueChanged<double> onChanged;

  const _PulseSliderCard({
    super.key,
    required this.question,
    required this.emoji,
    required this.valueLabel,
    required this.value,
    required this.color,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(question,
                    style: TextStyle(color: textColor, fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('1', style: TextStyle(color: subColor, fontSize: 11)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    inactiveTrackColor: color.withOpacity(0.2),
                    overlayColor: color.withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: value,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text('10', style: TextStyle(color: subColor, fontSize: 11)),
              const SizedBox(width: 8),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTrustRing extends StatelessWidget {
  final double score;
  final Color primary;

  const _MiniTrustRing({required this.score, required this.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            backgroundColor: primary.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
          Text(
            '${score.toInt()}',
            style: TextStyle(color: primary, fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
