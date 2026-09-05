import 'package:flutter/material.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/onboarding_screen/neutration_onboarding_screen.dart';
import 'package:healthmate/screens/auth_screens/main_auth_screen.dart';

const Color _bgStart = Color(0xFF10B981);
const Color _bgEnd = Color(0xFF059669);
const Color _accentPurple = Color(0xFF6C5CE7);

class TrackYourStepsScreen extends StatelessWidget {
  const TrackYourStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A2E);
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF9CA3AF);
    final bodyColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgStart, _bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const _ProgressDots(activeIndex: 0),
              const SizedBox(height: 10),

              // ── Card Container ──
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                    child: Column(
                      children: [
                        // Walker emoji
                        const Text('🚶', style: TextStyle(fontSize: 80)),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          'Track Your Steps',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Monitor your daily walking activity',
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                        const SizedBox(height: 10),

                        // Body text
                        Text(
                          'Keep track of every step you take throughout the day. Set goals, view history, and celebrate your achievements!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: bodyColor,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Feature rows
                        const _FeatureRow(
                          icon: Icons.trending_up_rounded,
                          iconColor: _accentPurple,
                          label: 'Daily step counter',
                        ),

                        const SizedBox(height: 8),
                        const _FeatureRow(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: _accentPurple,
                          label: 'Achievements & streaks',
                        ),
                        const SizedBox(height: 10),

                        // Example stats card
                        const _ExampleStatsCard(),
                        const SizedBox(height: 10),

                        // Footer buttons
                        const _FooterButtons(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int activeIndex;
  const _ProgressDots({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == activeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 32 : 20,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF3F4F6);
    final titleColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A2E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleStatsCard extends StatelessWidget {
  const _ExampleStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Example Stats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '8,234',
                  unit: 'steps',
                  period: 'Today',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCell(
                  value: '52,890',
                  unit: 'steps',
                  period: 'This Week',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCell(
                  value: '10,000',
                  unit: 'steps/day',
                  period: 'Goal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String unit;
  final String period;

  const _StatCell({
    required this.value,
    required this.unit,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            period,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterButtons extends StatelessWidget {
  const _FooterButtons();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skipBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF3F4F6);
    final skipText = isDark ? AppColors.darkTextSecondary : const Color(0xFF9CA3AF);

    return Row(
      children: [
        // Skip
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainAuthScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: skipBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Skip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: skipText,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Next
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NutritionTrackingScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
