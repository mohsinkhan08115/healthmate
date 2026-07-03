import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';

// ─── Metric enum ──────────────────────────────────────────────────────────────

enum HistoryMetric { steps, calories, protein, carbs, fat, fiber, water, runKm }

extension HistoryMetricExt on HistoryMetric {
  String get label {
    switch (this) {
      case HistoryMetric.steps:
        return 'Steps';
      case HistoryMetric.calories:
        return 'Calories';
      case HistoryMetric.protein:
        return 'Protein';
      case HistoryMetric.carbs:
        return 'Carbs';
      case HistoryMetric.fat:
        return 'Fat';
      case HistoryMetric.fiber:
        return 'Fiber';
      case HistoryMetric.water:
        return 'Water';
      case HistoryMetric.runKm:
        return 'Run';
    }
  }

  String get unit {
    switch (this) {
      case HistoryMetric.steps:
        return 'steps';
      case HistoryMetric.calories:
        return 'kcal';
      case HistoryMetric.water:
        return 'ml';
      case HistoryMetric.runKm:
        return 'km';
      default:
        return 'g';
    }
  }

  IconData get icon {
    switch (this) {
      case HistoryMetric.steps:
        return Icons.directions_walk_rounded;
      case HistoryMetric.calories:
        return Icons.local_fire_department_rounded;
      case HistoryMetric.protein:
        return Icons.fitness_center_rounded;
      case HistoryMetric.carbs:
        return Icons.breakfast_dining_rounded;
      case HistoryMetric.fat:
        return Icons.opacity_rounded;
      case HistoryMetric.fiber:
        return Icons.grass_rounded;
      case HistoryMetric.water:
        return Icons.water_drop_rounded;
      case HistoryMetric.runKm:
        return Icons.directions_run_rounded;
    }
  }

  Color get color {
    switch (this) {
      case HistoryMetric.steps:
        return const Color(0xFF5C6BC0);
      case HistoryMetric.calories:
        return const Color(0xFFEF6C00);
      case HistoryMetric.protein:
        return const Color(0xFF2E7D32);
      case HistoryMetric.carbs:
        return const Color(0xFFF9A825);
      case HistoryMetric.fat:
        return const Color(0xFFAD1457);
      case HistoryMetric.fiber:
        return const Color(0xFF558B2F);
      case HistoryMetric.water:
        return const Color(0xFF0277BD);
      case HistoryMetric.runKm:
        return const Color(0xFFD32F2F);
    }
  }
}

// ─── Day data model ───────────────────────────────────────────────────────────

// ─── Day data model ───────────────────────────────────────────────────────────

class _DayData {
  final DateTime date;
  final double steps;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double water;
  final double runKm;
  final List<String> foodNames;

  _DayData({
    required this.date,
    required this.steps,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.water,
    required this.runKm,
    required this.foodNames,
  });

  double valueOf(HistoryMetric m) {
    switch (m) {
      case HistoryMetric.steps:
        return steps;

      case HistoryMetric.calories:
        return calories;

      case HistoryMetric.protein:
        return protein;

      case HistoryMetric.carbs:
        return carbs;

      case HistoryMetric.fat:
        return fat;

      case HistoryMetric.fiber:
        return fiber;

      case HistoryMetric.water:
        return water;

      case HistoryMetric.runKm:
        return runKm;
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MonthlyHistory extends StatefulWidget {
  const MonthlyHistory({super.key});

  @override
  State<MonthlyHistory> createState() => _MonthlyHistoryState();
}

class _MonthlyHistoryState extends State<MonthlyHistory> {
  HistoryMetric _selected = HistoryMetric.steps;

  late final List<DateTime> _dates;
  List<_DayData> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(
      30,
      (i) => DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 29 - i)),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final stepsBox = Hive.box('stepsBox');
    final foodBox = Hive.box('foodBox');
    final controller = Get.find<DashboardController>();

    final usersData = foodBox.get('users', defaultValue: {}) as Map;
    final userFoods = (usersData[uid] ?? []) as List;

    final List<_DayData> result = [];

    for (final date in _dates) {
      final dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Steps
      final steps = (stepsBox.get('${uid}_$dateKey', defaultValue: 0) as num)
          .toDouble();

      // Water
      final water =
          (foodBox.get('${uid}_water_$dateKey', defaultValue: 0) as num)
              .toDouble();

      // Run KM (frozen value for that date)
      final runKm = controller.getFrozenRunKm(date);

      // Food totals
      double cal = 0;
      double pro = 0;
      double carbs = 0;
      double fat = 0;
      double fiber = 0;

      final List<String> dayFoodNames = [];

      for (final f in userFoods) {
        if (f['date'] == null) continue;

        try {
          final fd = DateTime.parse(f['date']);

          if (fd.year == date.year &&
              fd.month == date.month &&
              fd.day == date.day) {
            cal += (f['calories'] ?? 0).toDouble();
            pro += (f['protein'] ?? 0).toDouble();
            carbs += (f['carbs'] ?? 0).toDouble();
            fat += (f['fat'] ?? 0).toDouble();
            fiber += (f['Fiber'] ?? 0).toDouble();

            dayFoodNames.add(f['name'] ?? '');
          }
        } catch (_) {}
      }

      result.add(
        _DayData(
          date: date,
          steps: steps,
          calories: cal,
          protein: pro,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
          water: water,
          runKm: runKm,
          foodNames: dayFoodNames,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _data = result;
        _loading = false;
      });
    }
  }

  double get _monthTotal =>
      _data.fold(0.0, (sum, d) => sum + d.valueOf(_selected));

  double get _monthAvg => _data.isEmpty ? 0 : _monthTotal / _data.length;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _selected.color;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Monthly History',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric selector ──────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: HistoryMetric.values.map((m) {
                final active = m == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? m.color : m.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: active ? m.color : m.color.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.icon,
                          size: 15,
                          color: active ? Colors.white : m.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : m.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Summary strip ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _SummaryTile(
                  label: '30-day total',
                  value: _selected == HistoryMetric.steps
                      ? NumberFormat('#,###').format(_monthTotal.toInt())
                      : _monthTotal.toStringAsFixed(1),
                  unit: _selected.unit,
                  color: color,
                ),
                const SizedBox(width: 12),
                _SummaryTile(
                  label: 'Daily avg',
                  value: _selected == HistoryMetric.steps
                      ? NumberFormat('#,###').format(_monthAvg.toInt())
                      : _monthAvg.toStringAsFixed(1),
                  unit: _selected.unit,
                  color: color,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Last 30 days',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: scheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Per-day list ─────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final day = _data[_data.length - 1 - index];
                      final value = day.valueOf(_selected);
                      final isToday =
                          day.date.day == DateTime.now().day &&
                          day.date.month == DateTime.now().month &&
                          day.date.year == DateTime.now().year;

                      final maxVal = _data
                          .map((d) => d.valueOf(_selected))
                          .fold(0.0, (a, b) => a > b ? a : b);
                      final progress = maxVal == 0
                          ? 0.0
                          : (value / maxVal).clamp(0.0, 1.0);

                      return _DayRow(
                        date: day.date,
                        value: value,
                        unit: _selected.unit,
                        color: color,
                        progress: progress,
                        isToday: isToday,
                        isSteps: _selected == HistoryMetric.steps,
                        foodNames: day.foodNames,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary tile ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: '  $unit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Day row ──────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final DateTime date;
  final double value;
  final String unit;
  final Color color;
  final double progress;
  final bool isToday;
  final bool isSteps;
  final List<String> foodNames;

  const _DayRow({
    required this.date,
    required this.value,
    required this.unit,
    required this.color,
    required this.progress,
    required this.isToday,
    required this.isSteps,
    required this.foodNames,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasData = value > 0;
    final dateLabel = '${date.day}/${date.month}/${date.year}';
    final dayLabel = isToday ? 'Today' : DateFormat('EEE').format(date);

    final displayValue = isSteps
        ? NumberFormat('#,###').format(value.toInt())
        : value.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isToday
            ? color.withOpacity(0.07)
            : scheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: isToday
            ? Border.all(color: color.withOpacity(0.35), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isToday ? color : scheme.onSurface,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? color.withOpacity(0.7)
                            : scheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: hasData
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                displayValue,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? color : scheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                unit,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: color.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '—',
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.3),
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),

          if (foodNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              foodNames.join(', '),
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
