import 'package:cubebook/providers/statictics_summary_value.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/async_skeleton_wrapper.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/widgets/mini_metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingDaysTile extends StatisticsDashboardTileBase {
  const ReadingDaysTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.readingDaysTotal,
      title: l10n.tileReadingDaysTitle,
      description: l10n.tileReadingDaysDescription,
      columnSpan: 1,
      rowSpan: 1,
      icon: Icons.calendar_today_outlined,
    );
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue =
        ref.watch(staticticsSummaryValueProvider(StatisticType.totalDates));

    return AsyncSkeletonWrapper<int>(
      asyncValue: asyncValue,
      mock: 28,
      builder: (count, _) => LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxHeight * 0.4;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.yellow,
                  border: Border.all(width: 2, color: NeoBrutalColors.ink),
                ),
                child: Icon(
                  metadata.icon,
                  size: iconSize.clamp(16.0, 24.0),
                  color: NeoBrutalColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DashboardMiniMetric(
                  value: count,
                  label: l10nLocal.tileReadingDaysUnit,
                  icon: metadata.icon,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}