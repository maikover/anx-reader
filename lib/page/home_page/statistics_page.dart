import 'package:cubebook/dao/book.dart';
import 'package:cubebook/dao/reading_time.dart';
import 'package:cubebook/enums/chart_mode.dart';
import 'package:cubebook/enums/hint_key.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/page/book_detail.dart';
import 'package:cubebook/providers/statistic_data.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/date/convert_seconds.dart';
import 'package:cubebook/utils/date/week_of_year.dart';
import 'package:cubebook/widgets/bookshelf/book_cover.dart';
import 'package:cubebook/widgets/common/container/outlined_container.dart';
import 'package:cubebook/widgets/hint/hint_banner.dart';
import 'package:cubebook/widgets/statistic/statistic_card.dart';
import 'package:cubebook/widgets/statistic/statistics_dashboard_title.dart';
import 'package:cubebook/widgets/statistic/statistics_dashboard.dart';
import 'package:cubebook/widgets/tips/statistic_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key, this.controller});

  final ScrollController? controller;

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  int totalNumberOfBook = 0;
  int totalNumberOfDate = 0;
  int totalNumberOfNotes = 0;
  late final ScrollController _scrollController =
      widget.controller ?? ScrollController();

  void setNumbers() async {
    final numberOfBook = await readingTimeDao.selectTotalNumberOfBook();
    final numberOfDate = await readingTimeDao.selectTotalNumberOfDate();
    final numberOfNotes = await readingTimeDao.selectTotalNumberOfNotes();
    setState(() {
      totalNumberOfBook = numberOfBook;
      totalNumberOfDate = numberOfDate;
      totalNumberOfNotes = numberOfNotes;
    });
  }

  @override
  void initState() {
    setNumbers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(context.navBarStatistics),
      // ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              StatisticsDashboardTitle(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StatisticsDashboard(),
                                  const StatisticCard(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              children: const [
                                DateBooks(),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(
                                padding: const EdgeInsets.only(bottom: 80),
                                controller: _scrollController,
                                children: const [
                                  StatisticsDashboard(),
                                  StatisticCard(),
                                  SizedBox(height: 20),
                                  DateBooks(),
                                ]),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateBooks extends ConsumerStatefulWidget {
  const DateBooks({super.key});

  @override
  ConsumerState<DateBooks> createState() => _DateBooksState();
}

class _DateBooksState extends ConsumerState<DateBooks> {
  final TextStyle titleStyle = const TextStyle(
    fontSize: 30,
    fontFamily: 'SourceHanSerif',
    fontWeight: FontWeight.bold,
    overflow: TextOverflow.ellipsis,
  );

  List<int> deleteBookIds = [];

  @override
  void dispose() {
    super.dispose();
    if (deleteBookIds.isNotEmpty) {
      readingTimeDao.deleteReadingTimeByBookId(deleteBookIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statisticData = ref.watch(statisticDataProvider);

    Widget dragToDelete(Widget child, int bookId) {
      return StatefulBuilder(builder: (context, localSetState) {
        if (deleteBookIds.contains(bookId)) {
          return OutlinedContainer(
            margin: const EdgeInsets.only(bottom: 10),
            height: 146,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          size: 30,
                        ),
                        Text(
                          L10n.of(context).statisticDeletedRecords,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    FilledButton(
                        onPressed: () {
                          localSetState(() {
                            deleteBookIds.remove(bookId);
                          });
                        },
                        child: Text(L10n.of(context).commonUndo)),
                  ],
                ),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    Text(L10n.of(context).statisticDeletedRecordsTips),
                  ],
                ),
              ],
            ),
          );
        }
        ActionPane actionPane = ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                localSetState(() {
                  deleteBookIds.add(bookId);
                });
              },
              icon: Icons.delete,
              label: L10n.of(context).commonDelete,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ],
        );
        return Slidable(
          key: ValueKey(bookId),
          startActionPane: actionPane,
          endActionPane: actionPane,
          child: child,
        );
      });
    }

    return statisticData.when(
      data: (data) {
        final title = data.isSelectingDay
            ? data.date.toString().substring(0, 10)
            : data.mode == ChartMode.week
                ? weekOfYear(data.date)
                : data.mode == ChartMode.month
                    ? '${data.date.year}.${data.date.month}'
                    : data.mode == ChartMode.year
                        ? data.date.year.toString()
                        : L10n.of(context).statisticAllTime;

        final books = data.bookReadingTime;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                ],
              ),
            ),
            if (books.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: StatisticsTips(),
              )
            else
              Column(
                children: [
                  HintBanner(
                    icon: const Icon(Icons.swipe_left),
                    hintKey: HintKey.statisticsSwipeToDelete,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(L10n.of(context).statisticsSwipeToDeleteHint),
                  ),
                  ...books.map((bookMap) {
                    final book = bookMap.keys.first;
                    final readingTime = bookMap.values.first;
                    return dragToDelete(
                      BookStatisticItem(
                        bookId: book.id,
                        readingTime: readingTime,
                      ),
                      book.id,
                    );
                  })
                ],
              ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class BookStatisticItem extends StatelessWidget {
  const BookStatisticItem(
      {super.key, required this.bookId, required this.readingTime});

  final int bookId;
  final int readingTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Book>(
      future: bookDao.selectBookById(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final book = snapshot.data!;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookDetail(book: book)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
                border: Border.all(width: 4, color: NeoBrutalColors.ink),
                boxShadow: NeoBrutalColors.hardShadowMedium(),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: NeoBrutalColors.ink),
                      boxShadow: NeoBrutalColors.hardShadowSmall(),
                    ),
                    child: Hero(
                        tag: book.coverFullPath,
                        child: BookCover(
                          book: book,
                          height: 110,
                          width: 75,
                          radius: 0,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'SourceHanSerif',
                              fontWeight: FontWeight.bold,
                              color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: NeoBrutalColors.yellow,
                                  border:
                                      Border.all(width: 2, color: NeoBrutalColors.ink),
                                ),
                                child: Text(
                                  convertSeconds(readingTime),
                                  style: const TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: NeoBrutalColors.ink,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(book.readingPercentage * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? NeoBrutalColors.darkSurface
                                        : NeoBrutalColors.cream,
                                    border: Border.all(
                                        width: 2, color: NeoBrutalColors.ink),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: book.readingPercentage.clamp(0, 1),
                                    child: Container(
                                      color: NeoBrutalColors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
