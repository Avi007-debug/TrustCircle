import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/circle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/circle_provider.dart';
import '../../providers/pulse_provider.dart';
import '../../providers/gratitude_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.tealPrimary : AppColors.warmTeal;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final userAsync = ref.watch(currentUserProvider);
    final circlesAsync = ref.watch(userCirclesProvider);
    final activeCircle = ref.watch(activeCircleProvider);
    final trustScore = ref.watch(circleTrustScoreProvider);
    final trend = ref.watch(trustTrendProvider);
    final weeklyPulsesAsync = ref.watch(weeklyPulsesProvider);
    final gratitudeCount = ref.watch(gratitudeCountProvider);

    final userName = userAsync.asData?.value?.name ?? 'Friend';
    final circles = circlesAsync.asData?.value ?? [];
    final weeklyPulses = weeklyPulsesAsync.asData?.value ?? [];

    final healthLabel = _trustHealthLabel(trustScore);
    final healthColor = _trustHealthColor(trustScore);

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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded, color: primary, size: 16),
            ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            Text(
              'Hello, $userName! 👋',
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

            // ── Trust Ring + Stats Row ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E293B),
                          const Color(0xFF162030),
                        ]
                      : [
                          AppColors.lightSurface,
                          AppColors.warmTealLight,
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
              child: Row(
                children: [
                  // Trust Ring
                  _TrustRing(
                    score: trustScore,
                    color: healthColor,
                    primary: primary,
                    textColor: textColor,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trust Score',
                            style: TextStyle(color: subColor, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: healthColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            healthLabel,
                            style: TextStyle(
                                color: healthColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(trendIcon, color: trendColor, size: 18),
                            const SizedBox(width: 4),
                            Text(trend,
                                style: TextStyle(
                                    color: trendColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stats row
                        Row(
                          children: [
                            _MiniStat(
                              icon: '❤️',
                              value: '$gratitudeCount',
                              label: 'Posts',
                              textColor: textColor,
                              subColor: subColor,
                            ),
                            const SizedBox(width: 16),
                            _MiniStat(
                              icon: '🔥',
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 7-Day Trend Chart ──────────────────────────────────────────
            if (weeklyPulses.isNotEmpty) ...[
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
                    Text('7-Day Trend',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Your trust score over time',
                        style: TextStyle(color: subColor, fontSize: 12)),
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
                                  if (i < 0 || i >= weeklyPulses.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    DateFormat('E').format(
                                        weeklyPulses[i].timestamp),
                                    style: TextStyle(
                                        color: subColor, fontSize: 10),
                                  );
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
                          maxX: (weeklyPulses.length - 1).toDouble(),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: weeklyPulses
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      e.value.trustScore))
                                  .toList(),
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
                    Text('🌟', style: const TextStyle(fontSize: 40)),
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
                    isActive:
                        activeCircle?.id == circle.id,
                    trustScore: trustScore,
                    healthColor: healthColor,
                    healthLabel: healthLabel,
                    isDark: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primary: primary,
                    onTap: () {
                      ref.read(activeCircleIdProvider.notifier).set(
                          circle.id);
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
                    icon: '❤️',
                    label: 'Gratitude',
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
                    icon: '✨',
                    label: 'AI Insights',
                    onTap: () => context.push('/insights'),
                    primary: primary,
                    cardColor: cardColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
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
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Pulse'),
            BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_rounded),
                label: 'Gratitude'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded), label: 'Insights'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
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
  final String icon;
  final String value;
  final String label;
  final Color textColor;
  final Color subColor;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
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

class _CircleCard extends StatelessWidget {
  final CircleModel circle;
  final bool isActive;
  final double trustScore;
  final Color healthColor;
  final String healthLabel;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final Color borderColor;
  final Color primary;
  final VoidCallback onTap;

  const _CircleCard({
    required this.circle,
    required this.isActive,
    required this.trustScore,
    required this.healthColor,
    required this.healthLabel,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.borderColor,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                      Text(circle.name,
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
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
                  Text(
                    '${circle.members.length} members · ${circle.type}',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isActive ? '${trustScore.toInt()}%' : '--',
                  style: TextStyle(
                      color: isActive ? healthColor : subColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  isActive ? healthLabel : 'Select',
                  style: TextStyle(
                      color: isActive ? healthColor : subColor,
                      fontSize: 11),
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
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color primary;
  final Color cardColor;
  final Color textColor;
  final Color borderColor;

  const _QuickAction({
    required this.icon,
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
            Text(icon, style: const TextStyle(fontSize: 28)),
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
