import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/providers/last_read_book_provider.dart';
import 'package:cubebook/service/book.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/date/relative_time_formatter.dart';
import 'package:cubebook/widgets/bookshelf/book_cover.dart';
import 'package:cubebook/widgets/common/async_skeleton_wrapper.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContinueReadingTile extends StatisticsDashboardTileBase {
  const ContinueReadingTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.continueReading,
      title: l10n.tileContinueReadingTitle,
      description: l10n.tileContinueReadingDescription,
      columnSpan: 2,
      rowSpan: 1,
      icon: Icons.play_arrow_rounded,
    );
  }

  @override
  bool get canFlip => false;

  @override
  Widget buildCorner(BuildContext context, WidgetRef ref) {
    return cornerIcon(context, Icons.play_circle_outline);
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(lastReadBookProvider);

    return AsyncSkeletonWrapper<LastReadBookData?>(
      asyncValue: asyncValue,
      mock: LastReadBookData(
        book: Book.mock(),
        lastReadDate: DateTime.now(),
      ),
      builder: (data, _) {
        if (data == null) {
          return _EmptyState(
            onRefresh: () => ref.read(lastReadBookProvider.notifier).refresh(),
          );
        }
        final book = data.book;
        final heroTag = 'continue_reading_${book.id}';
        return _ContinueReadingContent(
          book: book,
          lastReadDate: data.lastReadDate,
          heroTag: heroTag,
        );
      },
    );
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) {
    final data = ref.read(lastReadBookProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final book = data?.book;
    if (book == null) return;
    final heroTag = 'continue_reading_${book.id}';
    pushToReadingPage(ref, context, book, heroTag: heroTag);
  }
}

class _ContinueReadingContent extends StatelessWidget {
  const _ContinueReadingContent({
    required this.book,
    required this.lastReadDate,
    required this.heroTag,
  });

  final Book book;
  final DateTime? lastReadDate;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = lastReadDate == null
        ? L10n.of(context).tileContinueReadingNoTimestamp
        : RelativeTimeFormatter.format(lastReadDate!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final coverWidth = constraints.maxHeight * 0.5;
        final progressHeight = constraints.maxHeight * 0.08;

        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: NeoBrutalColors.ink),
                boxShadow: NeoBrutalColors.hardShadowSmall(),
              ),
              child: Hero(
                tag: heroTag,
                child: BookCover(
                  book: book,
                  width: coverWidth.clamp(40.0, 60.0),
                  radius: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: progressHeight.clamp(4.0, 8.0),
                    decoration: BoxDecoration(
                      color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.cream,
                      border: Border.all(
                        width: 2,
                        color: NeoBrutalColors.borderColor(isDark),
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: book.readingPercentage.clamp(0, 1),
                      child: Container(
                        color: NeoBrutalColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 28,
          color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.tileContinueReadingEmptyState,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NeoBrutalColors.yellow,
              border: Border.all(width: 2, color: NeoBrutalColors.ink),
            ),
            child: Text(
              l10n.commonRefresh,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: NeoBrutalColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}