import 'package:cubebook/models/statistic_data_model.dart';
import 'package:cubebook/providers/book_daily_reading_provider.dart';
import 'package:cubebook/providers/statistic_data.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/date/convert_seconds.dart';
import 'package:cubebook/widgets/bookshelf/book_cover.dart';
import 'package:cubebook/widgets/common/async_skeleton_wrapper.dart';
import 'package:cubebook/widgets/statistic/book_reading_chart.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:cubebook/widgets/tips/statistic_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopBookTile extends StatisticsDashboardTileBase {
  const TopBookTile();

  @override
  get metadata => StatisticsDashboardTileMetadata(
        type: StatisticsDashboardTileType.topBook,
        title: l10nLocal.tileTopBookTitle,
        description: l10nLocal.tileTopBookDescription,
        columnSpan: 4,
        rowSpan: 2,
        icon: Icons.bookmark_added_outlined,
      );

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerIcon(context, Icons.favorite);
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AsyncSkeletonWrapper(
      asyncValue: ref.watch(statisticDataProvider),
      mock: StatisticDataModel.mock(),
      builder: (statisticData, _) {
        if (statisticData.bookReadingTime.isEmpty) {
          return Center(child: StatisticsTips());
        }
        final entry = statisticData.bookReadingTime.first;
        final book = entry.keys.first;
        final seconds = entry.values.first;

        return LayoutBuilder(
          builder: (context, constraints) {
            final coverWidth = constraints.maxHeight * 0.5;

            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: NeoBrutalColors.ink),
                    boxShadow: NeoBrutalColors.hardShadowSmall(),
                  ),
                  child: BookCover(
                    book: book,
                    width: coverWidth.clamp(60.0, 90.0),
                    radius: 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'SourceHanSerif',
                          fontWeight: FontWeight.bold,
                          color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: NeoBrutalColors.yellow,
                          border: Border.all(width: 2, color: NeoBrutalColors.ink),
                        ),
                        child: Text(
                          convertSeconds(seconds),
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: NeoBrutalColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: AsyncSkeletonWrapper(
                          asyncValue: ref.watch(
                            bookDailyReadingProvider(bookId: book.id),
                          ),
                          mock: BookDailyReadingData.mock(),
                          builder: (bookReadingData, ready) {
                            return ready
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? NeoBrutalColors.darkSurface
                                          : NeoBrutalColors.cream,
                                      border: Border.all(
                                          width: 2, color: NeoBrutalColors.ink),
                                    ),
                                    child: BookReadingChart(
                                      cumulativeValues: bookReadingData.readingTimes,
                                      dailySeconds: bookReadingData.readingTimes,
                                      dates: bookReadingData.dates,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}