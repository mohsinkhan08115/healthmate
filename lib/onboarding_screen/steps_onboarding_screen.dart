import 'package:flutter/material.dart';
import 'package:healthmate/onboarding_screen/neutration_onboarding_screen.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
const Color _bgStart = Color(0xFF5B7DE8);
const Color _bgEnd = Color(0xFF9B50E8);
const Color _titleColor = Color(0xFF1A1A2E);
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _bodyColor = Color(0xFF4B5563);
const Color _chipBg = Color(0xFFF3F4F6);
const Color _accentPurple = Color(0xFF7C5CE4);

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class TrackYourStepsScreen extends StatelessWidget {
  const TrackYourStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _ProgressDots(activeIndex: 0),
              const SizedBox(height: 10),

              // ── White card ──
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        const Text(
                          'Track Your Steps',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Monitor your daily walking activity',
                          style: TextStyle(fontSize: 14, color: _subtitleColor),
                        ),
                        const SizedBox(height: 10),

                        // Body text
                        const Text(
                          'Keep track of every step you take throughout the day. Set goals, view history, and celebrate your achievements!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _bodyColor,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Feature rows
                        _FeatureRow(
                          icon: Icons.trending_up_rounded,
                          iconColor: _accentPurple,
                          label: 'Daily step counter',
                        ),

                        const SizedBox(height: 8),
                        _FeatureRow(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: _accentPurple,
                          label: 'Achievements & streaks',
                        ),
                        const SizedBox(height: 10),

                        // Example stats card
                        _ExampleStatsCard(),
                        const SizedBox(height: 10),

                        // Footer buttons
                        _FooterButtons(),
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

// ─────────────────────────────────────────────
//  PROGRESS DOTS
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  FEATURE ROW
// ─────────────────────────────────────────────
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: _chipBg,
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EXAMPLE STATS CARD
// ─────────────────────────────────────────────
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
          colors: [Color(0xFF6A8AF8), Color(0xFF9B6AF8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Example Stats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
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

// ─────────────────────────────────────────────
//  FOOTER BUTTONS
// ─────────────────────────────────────────────
class _FooterButtons extends StatelessWidget {
  const _FooterButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Skip
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Skip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
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
                  builder: (context) => NutritionTrackingScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A8AF8), Color(0xFF9B6AF8)],
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
