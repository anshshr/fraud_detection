import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PercentagePieChart extends StatelessWidget {
  final double percentage; // Percentage value (0-100)
  final Color filledColor;
  final Color unfilledColor;

  const PercentagePieChart({
    Key? key,
    required this.percentage,
    this.filledColor = Colors.red,
    this.unfilledColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 60,
            sections: [
              PieChartSectionData(
                value: percentage,
                color: filledColor,
                showTitle: false,
                radius: 50,
              ),
              PieChartSectionData(
                value: 100 - percentage,
                color: unfilledColor,
                showTitle: false,
                radius: 50,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Risk \n Probability',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
