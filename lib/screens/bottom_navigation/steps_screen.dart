import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/step_counter_controller.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:healthmate/component_widgets/achivement_widgets.dart';
import 'package:healthmate/models/chart_model.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';

class StepsScreen extends StatelessWidget {
  StepsScreen({super.key});

  final StepsController controller = Get.put(StepsController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Today's steps card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Column(
                  children: [
                    Text(
                      "Today's Steps",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => SizedBox(
                        height: 140,
                        width: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 130,
                              width: 130,
                              child: CircularProgressIndicator(
                                value: controller.stepprogress.value.clamp(
                                  0.0,
                                  1.0,
                                ),
                                backgroundColor: AppColors.steps.withOpacity(isDark ? 0.2 : 0.12),
                                color: AppColors.steps,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.steps.value.toString(),
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "steps",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => Text(
                        "${(controller.stepprogress.value * 100).toStringAsFixed(0)}% of your 10,000 steps goal",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Weekly steps chart card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: SfCartesianChart(
                  legend: const Legend(isVisible: false),
                  title: ChartTitle(
                    text: "Weekly Activity",
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    alignment: ChartAlignment.near,
                  ),
                  margin: EdgeInsets.zero,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: AxisLine(width: 1, color: borderColor),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: borderColor,
                      dashArray: const [4, 4],
                    ),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                  series: [
                    ColumnSeries<ChartModel, String>(
                      dataSource: controller.chartData,
                      xValueMapper:
                          (d, _) => DateFormat('E').format(d.date), // Mon, Tue...
                      yValueMapper: (d, _) => d.value,
                      color: AppColors.steps,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      width: 0.5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.steps.withOpacity(isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.steps,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Total this week",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.weeklyStepsTotal.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.calories.withOpacity(isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.calories,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Daily average",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.dailyAverage.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
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

            // Achievements header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Achievements items
            AchievementWidget(
              icon: Icons.workspace_premium_rounded,
              text: "10K streak",
              subtext: "${controller.tenKStreak} days over 10,000 steps",
              day: controller.tenKStreak,
            ),
            AchievementWidget(
              icon: Icons.star_rounded,
              text: "Weekend warrior",
              subtext: controller.weekendWarrior
                  ? "Achieved on Saturday 🎉"
                  : "Not achieved yet",
              day: controller.weekendWarrior ? 1 : 0,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
