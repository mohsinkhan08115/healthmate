import 'package:flutter/material.dart';
import 'package:healthmate/onboarding_screen/water_onboarding_screen.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
const Color _bgStart = Color(0xFFFF6B35);
const Color _bgEnd = Color(0xFFE8105A);
const Color _titleColor = Color(0xFF1A1A2E);
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _bodyColor = Color(0xFF4B5563);
const Color _chipBg = Color(0xFFF3F4F6);
const Color _accentOrange = Color(0xFFFF6B35);
const Color _accentRed = Color(0xFFE8105A);

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class NutritionTrackingScreen extends StatelessWidget {
  const NutritionTrackingScreen({super.key});

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
              const SizedBox(height: 5),
              const _ProgressDots(activeIndex: 1),
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
                        // Apple emoji
                        const Text('🍎', style: TextStyle(fontSize: 80)),
                        const SizedBox(height: 5),

                        // Title
                        const Text(
                          'Nutrition Tracking',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Subtitle
                        const Text(
                          'Log your meals and monitor macros',
                          style: TextStyle(fontSize: 14, color: _subtitleColor),
                        ),
                        const SizedBox(height: 8),

                        // Body
                        const Text(
                          'Track your daily calories, protein, carbs, and fats. Get detailed nutrition info for every meal you eat!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _bodyColor,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Feature rows
                        const _FeatureRow(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: _accentOrange,
                          label: 'Calorie tracking',
                        ),
                        const SizedBox(height: 8),
                        const _FeatureRow(
                          icon: Icons.track_changes_rounded,
                          iconColor: _accentRed,
                          label: 'Protein & macro goals',
                        ),

                        const SizedBox(height: 8),

                        // Example stats card
                        const _ExampleStatsCard(),
                        const SizedBox(height: 8),

                        // Footer buttons
                        const _FooterButtons(),
                        const SizedBox(height: 8),

                        // Step indicator
                        const Text(
                          '2 of 3',
                          style: TextStyle(
                            fontSize: 13,
                            color: _subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
          colors: [Color(0xFFFF6B35), Color(0xFFE8105A)],
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
          const Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '1,450',
                  unit: 'kcal',
                  period: 'Calories',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCell(value: '95', unit: 'grams', period: 'Protein'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCell(
                  value: '4',
                  unit: 'logged today',
                  period: 'Meals',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CELL
// ─────────────────────────────────────────────
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            textAlign: TextAlign.center,
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
                MaterialPageRoute(builder: (context) => WaterIntakeScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFE8105A)],
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
