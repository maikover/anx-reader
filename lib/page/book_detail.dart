import 'dart:io';

import 'package:cubebook/dao/book.dart';
import 'package:cubebook/dao/reading_time.dart';
import 'package:cubebook/enums/hint_key.dart';
import 'package:cubebook/enums/sync_direction.dart';
import 'package:cubebook/enums/sync_trigger.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/models/book.dart';
import 'package:cubebook/models/reading_time.dart';
import 'package:cubebook/models/tag.dart';
import 'package:cubebook/providers/sync.dart';
import 'package:cubebook/providers/book_list.dart';
import 'package:cubebook/providers/tags.dart';
import 'package:cubebook/service/book.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/date/convert_seconds.dart';
import 'package:cubebook/utils/get_path/get_base_path.dart';
import 'package:cubebook/utils/log/common.dart';
import 'package:cubebook/utils/color/hash_color.dart';
import 'package:cubebook/widgets/bookshelf/book_cover.dart';
import 'package:cubebook/widgets/common/async_skeleton_wrapper.dart';
import 'package:cubebook/widgets/common/color_picker_sheet.dart';
import 'package:cubebook/widgets/common/tag_chip.dart';
import 'package:cubebook/widgets/hint/hint_banner.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookDetail extends ConsumerStatefulWidget {
  const BookDetail({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends ConsumerState<BookDetail> {
  late double rating;
  bool isEditing = false;
  final TextEditingController _newTagController = TextEditingController();
  Color? _pendingTagColor;

  @override
  void initState() {
    super.initState();
    rating = widget.book.rating;
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: NeoBrutalColors.white,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        child: const Icon(Icons.close, size: 20, color: NeoBrutalColors.ink),
      ),
    );
  }

  Widget _buildBookCover() {
    return GestureDetector(
      onTap: () async {
        if (!isEditing) return;

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null) return;

        File image = File(result.files.single.path!);

        AnxLog.info('BookDetail: Image path: ${image.path}');
        final File oldCoverImageFile = File(widget.book.coverFullPath);
        if (await oldCoverImageFile.exists()) {
          await oldCoverImageFile.delete();
        }

        String oldName = widget.book.coverPath
            .split('-')
            .sublist(0, widget.book.coverPath.split('-').length - 1)
            .join('');
        if (!oldName.startsWith('cover/')) {
          oldName = 'cover/$oldName';
        }

        String newPath =
            '$oldName-${DateTime.now().millisecondsSinceEpoch.toString()}.png'
                .trim();

        AnxLog.info('BookDetail: New path: $newPath');
        String newFullPath = getBasePath(newPath);

        final File newCoverImageFile = File(newFullPath);
        await newCoverImageFile.writeAsBytes(await image.readAsBytes());
        widget.book.coverPath = newPath;

        setState(() {
          widget.book.coverPath = newPath;
          bookDao.updateBook(widget.book);
          Sync().syncData(SyncDirection.upload, ref,
              trigger: SyncTrigger.auto);
          ref.read(bookListProvider.notifier).refresh();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 4, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowMedium(),
        ),
        child: Hero(
          tag: widget.book.coverFullPath,
          child: BookCover(
            book: widget.book,
            height: 200,
            width: 140,
            radius: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = widget.book.readingPercentage.clamp(0.0, 1.0);
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowMedium(),
        color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: normalized,
              strokeWidth: 8,
              backgroundColor: NeoBrutalColors.cream,
              color: NeoBrutalColors.red,
            ),
          ),
          Text(
            '${(normalized * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: NeoBrutalColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: NeoBrutalColors.yellow,
        border: Border.all(width: 3, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowSmall(),
      ),
      child: RatingBar.builder(
        initialRating: rating,
        minRating: 0,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 20,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: NeoBrutalColors.ink,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            this.rating = rating;
            updateBookRating(widget.book, rating);
          });
        },
      ),
    );
  }

  Widget _buildTitleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TextStyle titleStyle = TextStyle(
      fontSize: 22,
      fontFamily: 'SourceHanSerif',
      fontWeight: FontWeight.bold,
      color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
    );
    TextStyle authorStyle = TextStyle(
      fontSize: 14,
      fontFamily: 'SourceHanSerif',
      color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          autofocus: true,
          initialValue: widget.book.title,
          enabled: isEditing,
          style: titleStyle,
          maxLines: null,
          minLines: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            widget.book.title = value.replaceAll('\n', ' ');
          },
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: widget.book.author,
          enabled: isEditing,
          style: authorStyle,
          maxLines: null,
          minLines: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            widget.book.author = value;
          },
        ),
      ],
    );
  }

  Widget _buildNeoButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: NeoBrutalColors.ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: NeoBrutalColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: HintBanner(
            hintKey: HintKey.editBookDetails,
            margin: const EdgeInsets.only(right: 10),
            child: Text(
              L10n.of(context).bookDetailEditHint,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
              ),
            ),
          ),
        ),
        isEditing
            ? _buildNeoButton(
                icon: Icons.save,
                label: L10n.of(context).bookDetailSave,
                color: NeoBrutalColors.yellow,
                onPressed: () {
                  setState(() {
                    isEditing = false;
                    bookDao.updateBook(widget.book);
                    Sync().syncData(SyncDirection.upload, ref,
                        trigger: SyncTrigger.manual);
                    ref.read(bookListProvider.notifier).refresh();
                  });
                },
              )
            : _buildNeoButton(
                icon: Icons.edit,
                label: L10n.of(context).bookDetailEdit,
                color: NeoBrutalColors.white,
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
              ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 3,
      height: 40,
      color: NeoBrutalColors.ink,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildStatistics() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowMedium(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '#${widget.book.id}',
            L10n.of(context).bookDetailNthBook(widget.book.id),
          ),
          _buildStatDivider(),
          _buildStatItem(
            rating.toStringAsFixed(1),
            'Rating',
          ),
          _buildStatDivider(),
          FutureBuilder<int>(
            future: readingTimeDao.selectTotalReadingTimeByBookId(widget.book.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int total = snapshot.data!;
                int hours = total ~/ 3600;
                int minutes = (total % 3600) ~/ 60;
                return _buildStatItem(
                  '${hours}h ${minutes}m',
                  'Read time',
                );
              }
              return _buildStatItem('--', 'Read time');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagEditor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowMedium(),
      ),
      child: AsyncSkeletonWrapper(
        asyncValue: ref.watch(bookTagEditorProvider(widget.book.id)),
        builder: (state, _) {
          final notifier = ref.read(bookTagEditorProvider(widget.book.id).notifier);

          Future<void> showTagEditDialog(Tag tag) async {
            await TagChip.showEditDialog(
              context: context,
              initialName: tag.name,
              initialColor: tag.color ?? hashColor(tag.name),
              onRename: (newName) async {
                await ref.read(tagListProvider.notifier).updateTag(tag.id, newName: newName);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(widget.book.id));
              },
              onColorChange: (color) async {
                await ref.read(tagListProvider.notifier).updateTag(tag.id, color: color);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(widget.book.id));
              },
              onDelete: () async {
                await ref.read(tagListProvider.notifier).deleteTag(tag.id);
                await notifier.detach(tag);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(widget.book.id));
              },
            );
          }

          Future<void> toggle(Tag tag) async {
            final currentlySelected = state.isAttached(tag.id);
            if (currentlySelected) {
              await notifier.detach(tag);
            } else {
              await notifier.attachExisting(tag);
            }
            ref.read(bookListProvider.notifier).refresh();
          }

          final attachedTags = state.tags.where((t) => state.isAttached(t.id)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.yellow,
                      border: Border.all(width: 2, color: NeoBrutalColors.ink),
                    ),
                    child: Icon(Icons.label_outline, size: 16, color: NeoBrutalColors.ink),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.of(context).tagsSectionTitle,
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (attachedTags.isEmpty && !isEditing)
                HintBanner(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  hintKey: HintKey.addTags,
                  child: Text(
                    L10n.of(context).tagsEmptyHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                    ),
                  ),
                )
              else if (attachedTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: attachedTags
                      .map(
                        (tag) => TagChip(
                          label: tag.name,
                          color: tag.color,
                          selected: true,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTagController,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: L10n.of(context).tagNewPlaceholder,
                          isDense: true,
                          filled: true,
                          fillColor: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.cream,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(width: 3, color: NeoBrutalColors.ink),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(width: 3, color: NeoBrutalColors.ink),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(width: 3, color: NeoBrutalColors.ink),
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            final text = _newTagController.text.trim();
                            _pendingTagColor = text.isEmpty ? null : hashColor(text);
                          });
                        },
                        onSubmitted: (value) async {
                          if (value.trim().isEmpty) return;
                          final color = _pendingTagColor ?? hashColor(value.trim());
                          await notifier.createAndAttach(value.trim(), color: color);
                          ref.read(bookListProvider.notifier).refresh();
                          _newTagController.clear();
                          _pendingTagColor = null;
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(builder: (context) {
                      final currentText = _newTagController.text.trim();
                      final defaultColor =
                          _pendingTagColor ?? (currentText.isEmpty ? hashColor('tag') : hashColor(currentText));
                      return GestureDetector(
                        onTap: currentText.isEmpty
                            ? null
                            : () async {
                                final picked = await showRgbColorPicker(
                                  context: context,
                                  initialColor: defaultColor,
                                  allowAlpha: false,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _pendingTagColor = picked;
                                  });
                                }
                              },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: defaultColor,
                            border: Border.all(width: 2, color: NeoBrutalColors.ink),
                          ),
                          child: Icon(Icons.circle, size: 20, color: defaultColor),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final value = _newTagController.text.trim();
                        if (value.isEmpty) return;
                        final color = _pendingTagColor ?? hashColor(value);
                        await notifier.createAndAttach(value, color: color);
                        ref.read(bookListProvider.notifier).refresh();
                        _newTagController.clear();
                        _pendingTagColor = null;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: NeoBrutalColors.yellow,
                          border: Border.all(width: 3, color: NeoBrutalColors.ink),
                          boxShadow: NeoBrutalColors.hardShadowSmall(),
                        ),
                        child: Text(
                          L10n.of(context).tagAddButton,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: NeoBrutalColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  HintBanner(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    hintKey: HintKey.editOrRemoveTags,
                    child: Text(
                      L10n.of(context).tagsEditOrRemoveHint,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.tags
                        .map((tag) => TagChip(
                              label: tag.name,
                              color: tag.color,
                              selected: state.isAttached(tag.id),
                              onTap: () => toggle(tag),
                              onLongPress: () => showTagEditDialog(tag),
                              dense: false,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreDetails() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowMedium(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.yellow,
                  border: Border.all(width: 2, color: NeoBrutalColors.ink),
                ),
                child: Icon(Icons.info_outline, size: 16, color: NeoBrutalColors.ink),
              ),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            L10n.of(context).bookDetailImportDate,
            widget.book.createTime.toString().substring(0, 10),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            L10n.of(context).bookDetailLastReadDate,
            widget.book.updateTime.toString().substring(0, 10),
          ),
          const SizedBox(height: 12),
          Container(height: 3, color: NeoBrutalColors.ink),
          const SizedBox(height: 12),
          FutureBuilder<List<ReadingTime>>(
            future: readingTimeDao.selectReadingTimeByBookId(widget.book.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final readingTimes = snapshot.data!;
                if (readingTimes.isEmpty) {
                  return Text(
                    'No reading history',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                    ),
                  );
                }
                return Column(
                  children: readingTimes.take(5).map((rt) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            rt.dateOnly ?? rt.date ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? NeoBrutalColors.lightText : NeoBrutalColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            convertSeconds(rt.readingTime),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return const SizedBox(
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NeoBackground(
        pattern: NeoBackgroundPattern.grid,
        opacity: 0.05,
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildCloseButton(),
                    const Spacer(),
                    if (isEditing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: NeoBrutalColors.yellow,
                          border: Border.all(width: 3, color: NeoBrutalColors.ink),
                        ),
                        child: const Text(
                          'EDITING',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: NeoBrutalColors.ink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book info row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBookCover(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleSection(),
                                const SizedBox(height: 12),
                                _buildRatingBar(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress ring
                      Center(
                        child: _buildProgressRing(),
                      ),
                      const SizedBox(height: 16),
                      // Edit button
                      _buildEditButton(),
                      const SizedBox(height: 12),
                      // Statistics
                      _buildStatistics(),
                      const SizedBox(height: 12),
                      // Tags
                      _buildTagEditor(),
                      const SizedBox(height: 12),
                      // More details
                      _buildMoreDetails(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}