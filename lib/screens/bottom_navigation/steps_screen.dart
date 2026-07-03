import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/step_counter_controller.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:healthmate/component_widgets/achivement_widgets.dart';
import 'package:healthmate/models/chart_model.dart';

class StepsScreen extends StatelessWidget {
  StepsScreen({super.key});

  final StepsController controller = Get.put(StepsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Colors.blue,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset("assets/images/lifeline.png"),
                      title: Text("Steps Tracker"),
                      subtitle: Text("Track your daily movement"),
                    ),
                    Card(
                      elevation: 10,
                      color: Colors.blue[300],
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Today's Step"),
                          ),
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                controller.steps.value.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LinearProgressIndicator(
                                value: controller.stepprogress.value,
                              ),
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${(controller.stepprogress.value * 100).toStringAsFixed(0)}% of your 10,000 goal",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: SfCartesianChart(
                legend: Legend(isVisible: true),
                title: ChartTitle(text: "This Week Steps"),
                primaryXAxis: CategoryAxis(
                  interval: 2,
                  // labelIntersectAction: AxisLabelIntersectAction.none,
                  labelRotation: -45,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                series: [
                  ColumnSeries<ChartModel, String>(
                    dataSource: controller.chartData,
                    xValueMapper: (d, _) => DateFormat('MMM dd').format(d.date),
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) => d.color,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  child: Container(
                    height: 130,
                    width: 160,
                    color: Colors.amber,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month),
                        Text("Total This Week"),
                        Obx(() => Text("${controller.weeklyStepsTotal}")),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    height: 130,
                    width: 160,
                    color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up),
                        Text("Daily Average"),
                        Obx(
                          () =>
                              Text(controller.dailyAverage.toStringAsFixed(3)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AchievementWidget(
              icon: Icons.workspace_premium,
              text: "10K Streak!",
              subtext: "${controller.tenKStreak} days over 10,000 Steps",
              day: controller.tenKStreak,
            ),
            AchievementWidget(
              icon: Icons.star,
              text: "Weekend Warrior",
              subtext: controller.weekendWarrior
                  ? "Achieved on Saturday 🎉"
                  : "Not achieved yet",
              day: controller.weekendWarrior ? 1 : 0,
            ),
          ],
        ),
      ),
    );
  }
}
