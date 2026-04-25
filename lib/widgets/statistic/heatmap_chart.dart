import 'package:cubebook/providers/heatmap_data.dart';
import 'package:cubebook/providers/statistic_data.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeatmapChart extends ConsumerWidget {
  const HeatmapChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statisticData = ref.watch(heatmapDataProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: NeoBrutalColors.borderColor(isDark)),
      ),
      child: HeatMap(
        showColorTip: false,
        blockBorder: Border.all(
          color: NeoBrutalColors.borderColor(isDark),
          style: BorderStyle.solid,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        defaultColor: NeoBrutalColors.cardColor(isDark),
        datasets: statisticData.when(
            data: (data) => data, loading: () => {}, error: (error, stack) => {}),
        colorMode: ColorMode.opacity,
        showText: false,
        scrollable: true,
        colorsets: {
          1: NeoBrutalColors.adaptiveRed(isDark),
        },
        onClick: (value) {
          ref.read(statisticDataProvider.notifier).setIsSelectingDay(true, value);
        },
      ),
    );
  }
}
