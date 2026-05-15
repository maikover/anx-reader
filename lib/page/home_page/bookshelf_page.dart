import 'dart:io';
import 'dart:math';

import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/enums/hint_key.dart';
import 'package:cubebook/enums/sort_field.dart';
import 'package:cubebook/enums/sort_order.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/main.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/providers/book_list.dart';
import 'package:cubebook/providers/book_filters.dart';
import 'package:cubebook/providers/tags.dart';
import 'package:cubebook/service/book.dart';
import 'package:cubebook/page/search/search_page.dart';
import 'package:cubebook/utils/get_path/get_temp_dir.dart';
import 'package:cubebook/utils/platform_utils.dart';
import 'package:cubebook/utils/log/common.dart';
import 'package:cubebook/widgets/bookshelf/book_bottom_sheet.dart';
import 'package:cubebook/widgets/bookshelf/book_folder.dart';
import 'package:cubebook/widgets/bookshelf/sync_button.dart';
import 'package:cubebook/widgets/common/container/filled_container.dart';
import 'package:cubebook/widgets/common/tag_chip.dart';
import 'package:cubebook/widgets/hint/hint_banner.dart';
import 'package:cubebook/widgets/common/anx_segmented_button.dart';
import 'package:cubebook/widgets/tips/bookshelf_tips.dart';
import 'package:cubebook/widgets/neo/cube_book_logo.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path/path.dart' as p;

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key, this.controller});
  final ScrollController? controller;

  @override
  ConsumerState<BookshelfPage> createState() => BookshelfPageState();
}

class BookshelfPageState extends ConsumerState<BookshelfPage>
    with AutomaticKeepAliveClientMixin {
  late final _scrollController = widget.controller ?? ScrollController();
  final _gridViewKey = GlobalKey();
  bool _dragging = false;
  final GlobalKey _tagButtonKey = GlobalKey();
  final TextEditingController _editTagController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _editTagController.dispose();
    super.dispose();
  }

  Future<File> _copyToTempFile({
    required String sourcePath,
    required String fileName,
  }) async {
    final tempDir = await getAnxTempDir();
    final targetPath = p.join(tempDir.path, fileName);
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }
    return File(sourcePath).copy(targetPath);
  }

  Future<void> _importBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result == null) {
      return;
    }

    List<PlatformFile> files = result.files;
    AnxLog.info('importBook files: ${files.toString()}');
    List<File> fileList = [];
    // FilePicker on Windows will return files with original path,
    // but on Android it will return files with temporary path.
    // So we need to save the files to the temp directory.
    if (!AnxPlatform.isAndroid) {
      fileList = await Future.wait(files.map((file) async {
        return _copyToTempFile(sourcePath: file.path!, fileName: file.name);
      }).toList());
    } else {
      fileList = files.map((file) => File(file.path!)).toList();
    }

    importBookList(fileList, context, ref);
  }

  Future<void> _showTagMenu(BuildContext context, WidgetRef ref) async {
    final tags = ref.read(tagListProvider).whenOrNull(data: (value) => value) ?? [];
    final selectedTags = ref.read(tagSelectionProvider);
    final renderBox = _tagButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final boxMaxWidth = max(MediaQuery.of(context).size.width * 0.8, 500.0);

    await showMenu<int>(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      context: context,
      position: position,
      constraints: BoxConstraints(maxHeight: 360, maxWidth: boxMaxWidth),
      items: [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Align(
            alignment: Alignment.topRight,
            child: FilledContainer(
              constraints: BoxConstraints(maxHeight: 340, maxWidth: boxMaxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: StatefulBuilder(
                builder: (context, setStateMenu) {
                  final liveSelected = {...selectedTags};
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (tags.isEmpty)
                          Text(
                            L10n.of(context).tagsEmptyHint,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (tags.isNotEmpty)
                          TagChip(
                            label: L10n.of(context).noTagFilter,
                            color: Colors.grey,
                            selected: liveSelected.contains(kNoTagFilterId),
                            onTap: () {
                              setStateMenu(() {
                                if (liveSelected.contains(kNoTagFilterId)) {
                                  liveSelected.remove(kNoTagFilterId);
                                } else {
                                  liveSelected.clear();
                                  liveSelected.add(kNoTagFilterId);
                                }
                              });
                              ref.read(tagSelectionProvider.notifier).toggle(kNoTagFilterId);
                              ref.read(bookListProvider.notifier).refresh();
                            },
                            dense: false,
                          ),
                        for (final tag in tags)
                          TagChip(
                            label: tag.name,
                            color: tag.color,
                            selected: liveSelected.contains(tag.id),
                            onTap: () {
                              setStateMenu(() {
                                if (liveSelected.contains(tag.id)) {
                                  liveSelected.remove(tag.id);
                                } else {
                                  liveSelected.remove(kNoTagFilterId);
                                  liveSelected.add(tag.id);
                                }
                              });
                              ref.read(tagSelectionProvider.notifier).toggle(tag.id);
                              ref.read(bookListProvider.notifier).refresh();
                            },
                            dense: false,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final statusFilter = ref.watch(readingStatusFilterNotifierProvider);
    final selectedTags = ref.watch(tagSelectionProvider);
    final tagsAsync = ref.watch(tagListProvider);
    void handleBottomSheet(BuildContext context, Book book) {
      showBottomSheet(
        context: context,
        builder: (context) => BookBottomSheet(book: book),
      );
    }

    List<int> lockedIndices = [];

    Widget buildBookshelfBody = ref.watch(bookListProvider).when(
          data: (books) {
            for (int i = 0; i < books.length; i++) {
              // folder can't be dragged
              if (books[i].length != 1) {
                lockedIndices.add(i);
              }
            }
            return books.isEmpty
                ? const Center(child: BookshelfTips())
                : ReorderableBuilder(
                    // lock all index of books
                    lockedIndices: lockedIndices,
                    enableDraggable: true,
                    longPressDelay: const Duration(milliseconds: 300),
                    onReorder: (ReorderedListFunction reorderedListFunction) {},
                    scrollController: _scrollController,
                    onDragStarted: (index) {
                      if (books[index].length == 1) {
                        handleBottomSheet(context, books[index].first);
                        // add other books to lockedIndices
                        for (int i = 0; i < books.length; i++) {
                          if (i != index) {
                            lockedIndices.add(i);
                          }
                        }
                      }
                    },
                    onDragEnd: (index) {
                      // remove all books from lockedIndices
                      lockedIndices = [];
                      for (int i = 0; i < books.length; i++) {
                        if (books[i].length != 1) {
                          lockedIndices.add(i);
                        }
                      }
                      setState(() {});
                    },
                    children: [
                      ...books.map(
                        (book) {
                          final topLevelKey = ValueKey<String>(
                            book.first.id.toString(),
                          );
                          return book.length == 1
                              ? CustomDraggable(
                                  key: topLevelKey,
                                  data: book.first,
                                  child: BookFolder(books: book),
                                )
                              : BookFolder(
                                  key: topLevelKey,
                                  books: book,
                                );
                        },
                      ),
                    ],
                    builder: (children) {
                      return LayoutBuilder(builder: (context, constraints) {
                        return Column(
                          children: [
                            HintBanner(
                                icon: const Icon(Icons.copy),
                                hintKey: HintKey.dragAndDropToCreateFolder,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                child: Text(L10n.of(context)
                                    .dragAndDropToCreateFolderHint)),
                            Expanded(
                              child: GridView(
                                key: _gridViewKey,
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 80),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: constraints.maxWidth ~/
                                      Prefs().bookCoverWidth,
                                  childAspectRatio: 1 / 2.1,
                                  mainAxisSpacing: 30,
                                  crossAxisSpacing: 20,
                                ),
                                children: children,
                              ),
                            ),
                          ],
                        );
                      });
                    });
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
        );

    Widget body = Column(
      children: [
        // Logo centered at top
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CubeBookLogo(fontSize: 24),
              ],
            ),
          ),
        ),
        // Search bar + Sync/Sort buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      boxShadow: NeoBrutalColors.adaptiveShadowMedium(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchPage(),
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: L10n.of(context).searchBooksOrNotes,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SyncButton(),
              const SizedBox(width: 8),
              NeoIconButton(
                icon: Icons.sort,
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).padding.top + 100,
                      0.0,
                      0.0,
                    ),
                    items: [
                      for (var sortField in SortFieldEnum.values)
                        PopupMenuItem(
                            child: Text(
                              sortField.getL10n(context),
                              style: TextStyle(
                                color: sortField == Prefs().sortField
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              Prefs().sortField = sortField;
                              ref.read(bookListProvider.notifier).refresh();
                            }),
                      PopupMenuItem(
                        enabled: false,
                        child: StatefulBuilder(builder: (_, setState) {
                          return Row(
                            children: [
                              Expanded(
                                child: AnxSegmentedButton<SortOrderEnum>(
                                  onSelectionChanged: (value) {
                                    Prefs().sortOrder = value.first;
                                    ref.read(bookListProvider.notifier).refresh();
                                    setState(() {});
                                  },
                                  segments: SortOrderEnum.values
                                      .map(
                                        (e) => SegmentButtonItem(
                                          value: e,
                                          label: e.getL10n(
                                              navigatorKey.currentContext!),
                                        ),
                                      )
                                      .toList(),
                                  selected: {Prefs().sortOrder},
                                ),
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // Status filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusChip(
                        label: L10n.of(context).bookshelfFilterFinished,
                        selected: statusFilter == ReadingStatusFilter.finished,
                        onTap: () {
                          ref
                              .read(readingStatusFilterNotifierProvider.notifier)
                              .toggle(ReadingStatusFilter.finished);
                          ref.read(bookListProvider.notifier).refresh();
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: L10n.of(context).bookshelfFilterReading,
                        selected: statusFilter == ReadingStatusFilter.reading,
                        onTap: () {
                          ref
                              .read(readingStatusFilterNotifierProvider.notifier)
                              .toggle(ReadingStatusFilter.reading);
                          ref.read(bookListProvider.notifier).refresh();
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: L10n.of(context).bookshelfFilterNotStarted,
                        selected: statusFilter == ReadingStatusFilter.notStarted,
                        onTap: () {
                          ref
                              .read(readingStatusFilterNotifierProvider.notifier)
                              .toggle(ReadingStatusFilter.notStarted);
                          ref.read(bookListProvider.notifier).refresh();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NeoIconButton(
                key: _tagButtonKey,
                icon: EvaIcons.pricetags_outline,
                onPressed: () => _showTagMenu(context, ref),
                size: 40,
              ),
            ],
          ),
        ),
        // Tags row
        if (selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedTags
                    .where((id) => id != kNoTagFilterId)
                    .map((id) {
                  final tag = tagsAsync.whenOrNull(data: (tags) =>
                      {for (final t in tags) t.id: t}[id]);
                  if (tag == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TagChip(
                      label: tag.name,
                      color: tag.color,
                      selected: true,
                      onTap: () {
                        ref.read(tagSelectionProvider.notifier).toggle(tag.id);
                        ref.read(bookListProvider.notifier).refresh();
                      },
                      dense: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        // Neo-brutalist divider
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: NeoBrutalColors.ink,
        ),
        Expanded(
          child: DropTarget(
            onDragDone: (detail) async {
              List<File> files = [];
              for (var file in detail.files) {
                files.add(await _copyToTempFile(
                  sourcePath: file.path,
                  fileName: file.name,
                ));
              }
              importBookList(files, context, ref);
              setState(() {
                _dragging = false;
              });
            },
            onDragEntered: (detail) {
              setState(() {
                _dragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                _dragging = false;
              });
            },
            child: Stack(
              children: [
                buildBookshelfBody,
                if (_dragging)
                  Container(
                    color: Theme.of(context).colorScheme.surface.withAlpha(90),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            EvaIcons.arrowhead_down_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          Text(
                            L10n.of(context).bookshelfDragging,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    // Minimal AppBar - just for the scaffold, no content
    PreferredSizeWidget appBar = AppBar(
      forceMaterialTransparency: true,
      toolbarHeight: 0,
      elevation: 0,
    );

    return NeoBackground(
        pattern: NeoBackgroundPattern.mesh,
        opacity: 0.04,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 90),
            child: NeoIconButton(
              icon: Icons.add,
              onPressed: _importBook,
              size: 56,
              color: NeoBrutalColors.red,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: NeoFilterChip(
        label: label,
        selected: selected,
        onTap: onTap,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
