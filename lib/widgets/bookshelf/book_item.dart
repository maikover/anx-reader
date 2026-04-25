import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/enums/book_sync_status.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/providers/sync_status.dart';
import 'package:cubebook/service/book.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/bookshelf/book_bottom_sheet.dart';
import 'package:cubebook/widgets/bookshelf/book_cover.dart';
import 'package:cubebook/widgets/bookshelf/book_sync_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookItem extends ConsumerWidget {
  const BookItem({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> handleLongPress(BuildContext context) async {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return BookBottomSheet(book: book);
          });
    }

    BookSyncStatusEnum bookSyncStatus =
        ref.watch(syncStatusProvider).whenOrNull(data: (data) {
              if (data.downloading.contains(book.id)) {
                return BookSyncStatusEnum.downloading;
              } else if (data.uploading.contains(book.id)) {
                return BookSyncStatusEnum.uploading;
              } else if (data.localOnly.contains(book.id)) {
                return BookSyncStatusEnum.localOnly;
              } else if (data.remoteOnly.contains(book.id)) {
                return BookSyncStatusEnum.remoteOnly;
              } else if (data.both.contains(book.id)) {
                return BookSyncStatusEnum.both;
              } else if (data.nonExistent.contains(book.id)) {
                return BookSyncStatusEnum.nonExistent;
              } else {
                return BookSyncStatusEnum.checking;
              }
            }) ??
            BookSyncStatusEnum.checking;

    return GestureDetector(
      onTap: () {
        pushToReadingPage(ref, context, book);
      },
      onLongPress: () {
        handleLongPress(context);
      },
      onSecondaryTap: () {
        handleLongPress(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: book.coverFullPath,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: NeoBrutalColors.borderColor(isDark),
                  ),
                  boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BookCover(book: book),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 55,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (Prefs().webdavStatus)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: BookSyncStatusIcon(
                          syncStatus: bookSyncStatus,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.author,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 9,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Text(
                      '${(book.readingPercentage * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
