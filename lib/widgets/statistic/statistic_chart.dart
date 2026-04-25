import 'package:cubebook/providers/statistic_data.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/date/convert_seconds.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticChart extends ConsumerStatefulWidget {
  final List<int> readingTime;
  final List<String> xLabels;

  const StatisticChart(
      {super.key, required this.readingTime, required this.xLabels});

  @override
  ConsumerState<StatisticChart> createState() => _StatisticChartState();
}

class _StatisticChartState extends ConsumerState<StatisticChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Neo-brutalist adaptive color for bars
    final barColor = NeoBrutalColors.adaptiveRed(isDark);

    return BarChart(
      BarChartData(
        barTouchData: barTouchData(barColor, isDark),
        titlesData: titlesData(isDark),
        borderData: borderData,
        barGroups: barGroups(barColor, isDark),
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.readingTime
                .reduce((value, element) => value > element ? value : element) *
            1.2,
      ),
    );
  }

  BarTouchData barTouchData(Color barColor, bool isDark) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (BarChartGroupData group) {
          return Colors.transparent;
        },
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (touchedIndex != null && group.x.toInt() == touchedIndex) {
            return BarTooltipItem(
              convertSeconds(widget.readingTime[group.x.toInt()]),
              TextStyle(
                color: NeoBrutalColors.borderColor(isDark),
                fontWeight: FontWeight.bold,
                fontFamily: 'Space Grotesk',
                fontSize: 12,
              ),
            );
          }
          return null;
        },
      ),
      touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
        if (response?.spot != null) {
          setState(() {
            touchedIndex = response!.spot!.touchedBarGroupIndex;
            if (event is FlTapUpEvent) {
              if (widget.readingTime.length == 12) {
                ref
                    .read(statisticDataProvider.notifier)
                    .touchMonth(touchedIndex!);
              } else {
                ref
                    .read(statisticDataProvider.notifier)
                    .touchDay(widget.xLabels.length, touchedIndex!);
              }
            }
          });
        }
      },
    );
  }

  FlTitlesData titlesData(bool isDark) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => getTitles(value, meta, isDark),
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  List<BarChartGroupData> barGroups(Color barColor, bool isDark) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < widget.readingTime.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: widget.readingTime[i].toDouble(),
              // Neo-brutalist: solid red color with sharp corners
              color: barColor,
              width: 16,
              borderRadius: BorderRadius.zero,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: widget.readingTime.reduce(
                            (value, element) =>
                                value > element ? value : element) *
                        1.2 *
                        0.1,
                color: (isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.cream).withAlpha(128),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  SideTitleWidget getTitles(double value, TitleMeta meta, bool isDark) {
    final style = TextStyle(
      color: NeoBrutalColors.borderColor(isDark),
      fontWeight: FontWeight.bold,
      fontSize: 12,
      fontFamily: 'Space Grotesk',
    );
    return SideTitleWidget(
        meta: meta,
        child: Text(
          widget.xLabels[value.toInt()],
          style: style,
        ));
  }
}
