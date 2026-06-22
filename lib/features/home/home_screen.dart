import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/circle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/pulse_provider.dart';
import '../../providers/gratitude_provider.dart';
import '../../services/silence_detector_service.dart';
import '../../services/gemini_service.dart';
import '../../services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _showCircleGraph = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _trustHealthLabel(double score) {
    if (score >= AppConstants.excellentThreshold) return 'Excellent';
    if (score >= AppConstants.healthyThreshold) return 'Healthy';
    if (score >= AppConstants.watchThreshold) return 'Watch';
    return 'Risk';
  }

  Color _trustHealthColor(double score) {
    if (score >= AppConstants.excellentThreshold) return AppColors.excellent;
    if (score >= AppConstants.healthyThreshold) return AppColors.healthy;
    if (score >= AppConstants.watchThreshold) return AppColors.watch;
    return AppColors.risk;
  }

  void _showMembersSheet(BuildContext ctx, CircleModel circle, bool isDark, Color bgColor, Color textColor, Color subColor, Color primary) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: subColor.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text('${circle.name} Members', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: ref.read(firestoreServiceProvider).getUsersByIds(circle.members),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: primary));
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(child: Text('Failed to load members', style: TextStyle(color: subColor)));
                      }
                      
                      final members = snapshot.data!;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final m = members[index];
                          final name = m['name'] as String? ?? 'Anonymous';
                          final email = m['email'] as String? ?? '';
                          final uid = m['uid'] as String;
                          final isCreator = uid == circle.createdBy;
                          final currentUserIsAdmin = ref.read(currentUserProvider).asData?.value?.uid == circle.createdBy;
                          final isMe = uid == ref.read(currentUserProvider).asData?.value?.uid;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primary.withOpacity(0.15),
                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                            ),
                            title: Row(
                              children: [
                                Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                                if (isCreator) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.watch.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('Admin', style: TextStyle(color: AppColors.watch, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                            subtitle: Text(email, style: TextStyle(color: subColor, fontSize: 12)),
                            trailing: (currentUserIsAdmin && !isMe)
                                ? IconButton(
                                    icon: const Icon(Icons.person_remove_rounded, color: AppColors.risk, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: bgColor,
                                          title: Text('Remove Member', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                          content: Text('Are you sure you want to remove $name from ${circle.name}?', style: TextStyle(color: subColor)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: subColor))),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.risk, foregroundColor: Colors.white),
                                              onPressed: () async {
                                                await ref.read(firestoreServiceProvider).removeMember(circle.id, uid);
                                                if (ctx.mounted) {
                                                  Navigator.pop(ctx);
                                                  Navigator.pop(sheetCtx);
                                                }
                                              },
                                              child: const Text('Remove'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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

    final userAsync = ref.watch(currentUserProvider);
    final circlesAsync = ref.watch(userCirclesProvider);
    final activeCircle = ref.watch(activeCircleProvider);
    final trustScore = ref.watch(circleTrustScoreProvider);
    final myTrustScore = ref.watch(individualTrustScoreProvider);
    final trend = ref.watch(trustTrendProvider);
    final weeklyPulsesAsync = ref.watch(weeklyPulsesProvider);
    final gratitudeCount = ref.watch(gratitudeCountProvider);

    final userName = userAsync.asData?.value?.name ?? 'Friend';
    final circles = circlesAsync.asData?.value ?? [];
    final weeklyPulses = weeklyPulsesAsync.asData?.value ?? [];
    final circleDailyAverages = ref.watch(circleDailyAveragesProvider);
    final circleDailyDates = ref.watch(circleDailyDatesProvider);

    final healthLabel = _trustHealthLabel(trustScore);
    final healthColor = _trustHealthColor(trustScore);
    
    final myHealthLabel = _trustHealthLabel(myTrustScore);
    final myHealthColor = _trustHealthColor(myTrustScore);

    final circlePulsesAsync = ref.watch(circlePulsesProvider);
    final silentMembersAsync = ref.watch(silentMembersProvider);
    final silentMembers = silentMembersAsync.asData?.value ?? [];

    // Auto-fire resolve notification when trust score is low
    if (!circlePulsesAsync.isLoading && circlePulsesAsync.hasValue && circlePulsesAsync.value!.isNotEmpty) {
      if (trustScore < AppConstants.watchThreshold && activeCircle != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notificationService.showResolveNotification(activeCircle.name, trustScore);
        });
      }
    }

    // Build trend icon & label
    IconData trendIcon;
    Color trendColor;
    if (trend == 'Improving') {
      trendIcon = Icons.trending_up_rounded;
      trendColor = AppColors.excellent;
    } else if (trend == 'Declining') {
      trendIcon = Icons.trending_down_rounded;
      trendColor = AppColors.risk;
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = AppColors.watch;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 36, height: 36),
            const SizedBox(width: 10),
            Text(
              'TrustCircle',
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: subColor),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primary.withOpacity(0.2),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            Text(
              'Hello, $userName',
              style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(color: subColor, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // ── Silence Detector ────────────────────────────────────────────
            if (activeCircle != null && silentMembers.isNotEmpty)
              Builder(
                builder: (context) {
                  final isFamily = activeCircle.type == 'Family';
                  final currentUserId = userAsync.asData?.value?.uid;
                  
                  final othersSilent = silentMembers.where((m) => m['uid'] != currentUserId).toList();
                  final amISilent = silentMembers.any((m) => m['uid'] == currentUserId);
                  final mySilentData = amISilent ? silentMembers.firstWhere((m) => m['uid'] == currentUserId) : null;

                  if (silentMembers.length == 1) {
                    if (isFamily) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.watch.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.watch.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.family_restroom_rounded, color: AppColors.watch, size: 28),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text('Family Silence Alert', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.watch, shape: BoxShape.circle)),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(amISilent ? 'You — ${mySilentData!['daysSilent']} days silent' : '${othersSilent.first['name']} — ${othersSilent.first['daysSilent']} days silent',
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(amISilent 
                              ? 'Your family is waiting to hear from you. Please check in.'
                              : 'Reach out to your family. They may need you.',
                              style: const TextStyle(color: AppColors.watch, fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.watch.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: AppColors.watch, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(amISilent ? 'You haven\'t checked in recently' : '${othersSilent.first['name']} may need support',
                                style: const TextStyle(color: AppColors.watch, fontWeight: FontWeight.w500, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    // >= 2 people silent
                    String title;
                    if (amISilent) {
                      title = 'You and ${othersSilent.length} others need to check in';
                    } else {
                      title = '${othersSilent.first['name']} and ${othersSilent.length - 1} more may need support';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.watch.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: AppColors.watch, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(title,
                              style: const TextStyle(color: AppColors.watch, fontWeight: FontWeight.w500, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.watch,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

            // ── Resolve Mode ────────────────────────────────────────────────
            if (trustScore < AppConstants.watchThreshold && activeCircle != null)
              Builder(builder: (ctx) {
                final isFamily = activeCircle.type == 'Family';

                if (isFamily) {
                  // ── FAMILY: Full Banner ──
                  return GestureDetector(
                    onTap: () => context.push('/resolve'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.risk.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.risk.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.healing_rounded, color: AppColors.risk, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Resolve Mode Available', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Trust score dropped to ${trustScore.toStringAsFixed(0)}%. Tap to get AI guidance.',
                                  style: const TextStyle(color: AppColors.risk, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.risk, size: 16),
                        ],
                      ),
                    ),
                  );
                } else {
                  // ── OTHER: Compact Bubble ──
                  return GestureDetector(
                    onTap: () => context.push('/resolve'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.risk.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.risk, size: 18),
                          const SizedBox(width: 8),
                          Text('Trust dropping — Resolve Mode',
                            style: const TextStyle(color: AppColors.risk, fontWeight: FontWeight.w500, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.risk, size: 12),
                        ],
                      ),
                    ),
                  );
                }
              }),

            // ── Dual Trust Rings + Stats ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF162030),
                        ]
                      : [
                          AppColors.lightSurface,
                          const Color(0xFFD6E9F2),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(isDark ? 0.1 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // My Pulse
                      Column(
                        children: [
                          Text('My Pulse', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _TrustRing(
                            score: myTrustScore,
                            color: myHealthColor,
                            primary: primary,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 8),
                          Text(myHealthLabel, style: TextStyle(color: myHealthColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(width: 1, height: 80, color: borderColor),
                      // Circle Pulse
                      Column(
                        children: [
                          Text('Circle Pulse', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _TrustRing(
                            score: trustScore,
                            color: healthColor,
                            primary: primary,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 8),
                          Text(healthLabel, style: TextStyle(color: healthColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 18),
                      const SizedBox(width: 4),
                      Text('Trend: $trend',
                          style: TextStyle(
                              color: trendColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                        // Stats row
                        Row(
                          children: [
                            _MiniStat(
                              iconData: Icons.volunteer_activism_rounded,
                              value: '$gratitudeCount',
                              label: 'Posts',
                              textColor: textColor,
                              subColor: subColor,
                            ),
                            const SizedBox(width: 16),
                            _MiniStat(
                              iconData: Icons.timeline_rounded,
                              value:
                                  '${weeklyPulses.isNotEmpty ? weeklyPulses.length : 0}',
                              label: 'Check-ins',
                              textColor: textColor,
                              subColor: subColor,
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 7-Day Trend Chart ──────────────────────────────────────────
            if (weeklyPulses.isNotEmpty || circleDailyAverages.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Graph Toggle
                    Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ToggleButtons(
                            constraints: BoxConstraints(
                              minHeight: 34,
                              minWidth: (constraints.maxWidth / 2) - 2,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            selectedColor: Colors.white,
                            color: subColor,
                            fillColor: primary,
                            renderBorder: false,
                            isSelected: [!_showCircleGraph, _showCircleGraph],
                            onPressed: (index) {
                              setState(() {
                                _showCircleGraph = index == 1;
                              });
                            },
                            children: const [
                              Text('My Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Circle Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('7-Day Trend',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_showCircleGraph ? 'Circle average over time' : 'Your trust score over time',
                            style: TextStyle(color: subColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: borderColor,
                              strokeWidth: 0.5,
                            ),
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 50,
                                getTitlesWidget: (value, meta) => Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                      color: subColor, fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (_showCircleGraph) {
                                    if (i < 0 || i >= circleDailyDates.length) return const SizedBox.shrink();
                                    return Text(DateFormat('E').format(circleDailyDates[i]), style: TextStyle(color: subColor, fontSize: 10));
                                  } else {
                                    if (i < 0 || i >= weeklyPulses.length) return const SizedBox.shrink();
                                    return Text(DateFormat('E').format(weeklyPulses[i].timestamp), style: TextStyle(color: subColor, fontSize: 10));
                                  }
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: _showCircleGraph 
                              ? (circleDailyAverages.isEmpty ? 0 : circleDailyAverages.length - 1).toDouble() 
                              : (weeklyPulses.isEmpty ? 0 : weeklyPulses.length - 1).toDouble(),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _showCircleGraph
                                  ? circleDailyAverages
                                  : weeklyPulses.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.trustScore)).toList(),
                              isCurved: true,
                              color: primary,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) =>
                                    FlDotCirclePainter(
                                  radius: 3,
                                  color: primary,
                                  strokeColor: cardColor,
                                  strokeWidth: 1.5,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primary.withOpacity(0.08),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Daily Check-In CTA ─────────────────────────────────────────
            GestureDetector(
              onTap: () => context.push('/checkin'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Trust Pulse',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Circle Selection ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Circles',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/circles/join'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: primary.withOpacity(0.3), width: 1),
                        ),
                        child: Text('Join',
                            style: TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/circles/create'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('+ New',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (circles.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.group_add_rounded, size: 48, color: primary),
                    const SizedBox(height: 12),
                    Text('No circles yet',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Create or join a circle to start measuring trust',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...circles.map((circle) => _CircleCard(
                    circle: circle,
                    currentUid: userAsync.asData?.value?.uid ?? '',
                    isActive:
                        activeCircle?.id == circle.id,
                    isDark: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primary: primary,
                    onTap: () {
                      ref.read(activeCircleIdProvider.notifier).set(circle.id);
                    },
                    onViewMembers: () => _showMembersSheet(context, circle, isDark, bgColor, textColor, subColor, primary),
                    onLeave: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: bgColor,
                          title: Text('Leave Circle', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          content: Text('Are you sure you want to leave ${circle.name}?', style: TextStyle(color: subColor)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: subColor))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.risk, foregroundColor: Colors.white),
                              onPressed: () async {
                                await ref.read(firestoreServiceProvider).leaveCircle(circle.id, userAsync.asData!.value!.uid);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: bgColor,
                          title: Text('Delete Circle', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          content: Text('Are you sure you want to permanently delete ${circle.name}?', style: TextStyle(color: subColor)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: subColor))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.risk, foregroundColor: Colors.white),
                              onPressed: () async {
                                await ref.read(firestoreServiceProvider).deleteCircle(circle.id);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ],

            const SizedBox(height: 20),

            // ── Quick actions ─────────────────────────────────────────────
            Text('Quick Actions',
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    iconData: Icons.volunteer_activism_rounded,
                    label: 'Appreciation',
                    onTap: () => context.push('/gratitude'),
                    primary: primary,
                    cardColor: cardColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    iconData: Icons.psychology_alt_rounded,
                    label: 'AI Wisdom',
                    onTap: () => context.push('/insights'),
                    primary: primary,
                    cardColor: cardColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
            
            // ── Silence Dropdown ───────────────────────────────────────────
            if (activeCircle != null && silentMembers.length >= 2) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: const Icon(Icons.people_outline_rounded, color: AppColors.watch),
                    title: const Text('Members Needing Support', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${silentMembers.length} people haven\'t checked in recently', style: TextStyle(color: subColor, fontSize: 12)),
                    iconColor: AppColors.watch,
                    collapsedIconColor: subColor,
                    children: [
                      Container(height: 1, color: borderColor),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: silentMembers.length,
                        itemBuilder: (context, index) {
                          final m = silentMembers[index];
                          final isMe = m['uid'] == userAsync.asData?.value?.uid;
                          final name = isMe ? 'You' : m['name'];
                          
                          return ListTile(
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.watch.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.watch, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                            title: Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                            trailing: Text('${m['daysSilent']} days', style: const TextStyle(color: AppColors.watch, fontWeight: FontWeight.bold, fontSize: 13)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() => _currentIndex = i);
            switch (i) {
              case 1:
                context.push('/checkin');
                break;
              case 2:
                context.push('/gratitude');
                break;
              case 3:
                context.push('/insights');
                break;
              case 4:
                context.push('/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Sanctuary'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Trust Pulse'),
            BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_rounded),
                label: 'Appreciation'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded), label: 'AI Wisdom'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'My Aura'),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _TrustRing extends StatelessWidget {
  final double score;
  final Color color;
  final Color primary;
  final Color textColor;

  const _TrustRing({
    required this.score,
    required this.color,
    required this.primary,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text('Trust',
                  style: TextStyle(
                      color: color, fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData iconData;
  final String value;
  final String label;
  final Color textColor;
  final Color subColor;

  const _MiniStat({
    required this.iconData,
    required this.value,
    required this.label,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.tealPrimary : AppColors.lavenderPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, size: 16, color: primary),
            const SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        Text(label, style: TextStyle(color: subColor, fontSize: 11)),
      ],
    );
  }
}

class _CircleCard extends ConsumerWidget {
  final CircleModel circle;
  final String currentUid;
  final bool isActive;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final Color borderColor;
  final Color primary;
  final VoidCallback onTap;
  final VoidCallback onViewMembers;
  final VoidCallback onLeave;
  final VoidCallback onDelete;

  const _CircleCard({
    required this.circle,
    required this.currentUid,
    required this.isActive,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.borderColor,
    required this.primary,
    required this.onTap,
    required this.onViewMembers,
    required this.onLeave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(specificCircleScoreProvider(circle.id));
    final score = scoreAsync.asData?.value ?? 0.0;
    final hasData = scoreAsync.hasValue && score > 0;
    
    final healthColor = score >= 70
        ? AppColors.healthy
        : (score >= 40 ? AppColors.watch : AppColors.risk);
    final healthLabel = score >= 70
        ? 'Healthy'
        : (score >= 40 ? 'Needs Attention' : 'At Risk');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? primary : borderColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  circle.name.isNotEmpty ? circle.name[0].toUpperCase() : '?',
                  style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(circle.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Active',
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: onViewMembers,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_alt_rounded, color: primary, size: 12),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${circle.members.length} Members',
                                  style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '· ${circle.type}',
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                      if (isActive)
                        GestureDetector(
                          onTap: () {
                            Share.share('Join my TrustCircle using code: ${circle.inviteCode}\nDownload the app to connect!');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share_rounded, color: primary, size: 12),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Code: ${circle.inviteCode}',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasData ? '${score.toInt()}%' : '--',
                      style: TextStyle(
                          color: hasData ? healthColor : subColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: subColor, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'leave') onLeave();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (BuildContext context) => [
                        if (circle.createdBy != currentUid)
                          const PopupMenuItem(
                            value: 'leave',
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app_rounded, color: AppColors.risk, size: 18),
                                SizedBox(width: 8),
                                Text('Leave Circle', style: TextStyle(color: AppColors.risk)),
                              ],
                            ),
                          ),
                        if (circle.createdBy == currentUid)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, color: AppColors.risk, size: 18),
                                SizedBox(width: 8),
                                Text('Delete Circle', style: TextStyle(color: AppColors.risk)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 28), // align under the percentage
                  child: Text(
                    hasData ? healthLabel : 'Select',
                    style: TextStyle(
                        color: hasData ? healthColor : subColor,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;
  final Color primary;
  final Color cardColor;
  final Color textColor;
  final Color borderColor;

  const _QuickAction({
    required this.iconData,
    required this.label,
    required this.onTap,
    required this.primary,
    required this.cardColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
