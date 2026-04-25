import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/providers/reading_completion_provider.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/async_skeleton_wrapper.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletionProgressTile extends StatisticsDashboardTileBase {
  const CompletionProgressTile();

  @override
  StatisticsDashboardTileMetadata get metadata {
    final l10n = l10nLocal;
    return StatisticsDashboardTileMetadata(
      type: StatisticsDashboardTileType.completionProgress,
      title: l10n.tileCompletionProgressTitle,
      description: l10n.tileCompletionProgressDescription,
      columnSpan: 4,
      rowSpan: 2,
      icon: Icons.emoji_events_outlined,
    );
  }

  @override
  String get title => metadata.title;

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(readingCompletionProvider);
    return AsyncSkeletonWrapper<List<Book>>(
      asyncValue: asyncValue,
      mock: [Book.mock()],
      builder: (books, _) => _CompletionContent(books: books),
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context);
    final average = books.isEmpty
        ? 0.0
        : books.fold<double>(0, (acc, book) => acc + book.readingPercentage) /
            books.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = constraints.maxHeight * 0.4;
        final usableHeight = constraints.maxHeight;
        final topSectionHeight = usableHeight * 0.45;
        final listSectionHeight = usableHeight * 0.50;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with ring and summary
            SizedBox(
              height: topSectionHeight,
              child: Row(
                children: [
                  // Neo ring
                  Container(
                    width: ringSize.clamp(50.0, 70.0),
                    height: ringSize.clamp(50.0, 70.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: NeoBrutalColors.ink),
                      boxShadow: NeoBrutalColors.hardShadowSmall(),
                      color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: ringSize.clamp(40.0, 55.0),
                          height: ringSize.clamp(40.0, 55.0),
                          child: CircularProgressIndicator(
                            value: average.clamp(0, 1),
                            strokeWidth: 6,
                            backgroundColor: NeoBrutalColors.cream,
                            color: NeoBrutalColors.red,
                          ),
                        ),
                        Text(
                          '${(average * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: ringSize * 0.18,
                            color: NeoBrutalColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.tileCompletionProgressAverageLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: NeoBrutalColors.yellow,
                            border: Border.all(width: 2, color: NeoBrutalColors.ink),
                          ),
                          child: Text(
                            '${books.length} books',
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: NeoBrutalColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 2, color: NeoBrutalColors.ink),
            const SizedBox(height: 4),
            // Book list
            SizedBox(
              height: listSectionHeight,
              child: books.isEmpty
                  ? Center(
                      child: Text(
                        l10n.tileCompletionProgressEmptyState,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: books.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final percent = (book.readingPercentage * 100)
                            .clamp(0, 100)
                            .toStringAsFixed(0);
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'SourceHanSerif',
                                  color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: NeoBrutalColors.red,
                                border: Border.all(width: 2, color: NeoBrutalColors.ink),
                              ),
                              child: Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  color: NeoBrutalColors.ink,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 3),
                    ),
            ),
          ],
        );
      },
    );
  }
}