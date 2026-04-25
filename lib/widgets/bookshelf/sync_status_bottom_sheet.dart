import 'dart:io';

import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/enums/book_sync_status.dart';
import 'package:cubebook/enums/sync_direction.dart';
import 'package:cubebook/enums/sync_trigger.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/main.dart';
import 'package:cubebook/models/sync_state_model.dart';
import 'package:cubebook/providers/sync.dart';
import 'package:cubebook/providers/sync_status.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/get_path/databases_path.dart';
import 'package:cubebook/utils/toast/common.dart';
import 'package:cubebook/widgets/bookshelf/book_sync_status_icon.dart';
import 'package:cubebook/widgets/linear_proportion_bar.dart';
import 'package:cubebook/widgets/neo/neo_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

Future<void> showSyncStatusBottomSheet(BuildContext context) async {
  final dbPath = await getAnxDataBasesPath();
  showModalBottomSheet(
    useSafeArea: true,
    context: navigatorKey.currentContext!,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SyncStatusBottomSheet(dbPath: dbPath),
  );
}

class SyncStatusBottomSheet extends ConsumerWidget {
  const SyncStatusBottomSheet({super.key, required this.dbPath});

  final String dbPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final l10n = L10n.of(context);

    final int localOnlyBooks = ref.watch(syncStatusProvider).whenOrNull(
              data: (data) => data.localOnly.length,
            ) ??
        0;
    final int remoteOnlyBooks = ref.watch(syncStatusProvider).whenOrNull(
              data: (data) => data.remoteOnly.length,
            ) ??
        0;
    final int bothBooks = ref.watch(syncStatusProvider).whenOrNull(
              data: (data) => data.both.length,
            ) ??
        0;
    final int nonExistentBooks = ref.watch(syncStatusProvider).whenOrNull(
              data: (data) => data.nonExistent.length,
            ) ??
        0;
    File localDb = File(join((dbPath), 'app_database.db'));
    final DateTime localUpdateTime = localDb.lastModifiedSync();

    final DateTime? lastUploadTime = Prefs().lastUploadBookDate;

    return Container(
      color: NeoBrutalColors.cream,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            _buildSyncingIndicator(syncState, l10n),
            const SizedBox(height: 16),

            // Time info panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeoBrutalColors.white,
                border: Border.all(width: 4, color: NeoBrutalColors.ink),
                boxShadow: NeoBrutalColors.hardShadowSmall(),
              ),
              child: _buildUpdateTimeInfo(localUpdateTime, lastUploadTime, l10n),
            ),
            const SizedBox(height: 20),

            // Section title — Book Distribution
            _NeoSectionLabel(label: l10n.bookSyncStatusBothBooks.split(' ').take(2).join(' ').toUpperCase()),
            const SizedBox(height: 0),

            // Distribution chart
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeoBrutalColors.white,
                border: Border.all(width: 4, color: NeoBrutalColors.ink),
                boxShadow: NeoBrutalColors.hardShadowSmall(),
              ),
              child: Column(
                children: [
                  _buildBookDistributionChart(
                      localOnlyBooks, remoteOnlyBooks, bothBooks, nonExistentBooks),
                  const SizedBox(height: 12),
                  _buildBookStats(
                      localOnlyBooks, remoteOnlyBooks, bothBooks, nonExistentBooks, l10n),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildNonExistentTip(l10n),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context, ref, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildNonExistentTip(L10n l10n) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 14, color: NeoBrutalColors.ink),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.bookSyncStatusNonExistentTip,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: NeoBrutalColors.ink,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncingIndicator(SyncStateModel syncState, L10n l10n) {
    String byteToHuman(int byte) {
      if (byte < 1024) return '$byte B';
      if (byte < 1024 * 1024) return '${(byte / 1024).toStringAsFixed(2)} KB';
      if (byte < 1024 * 1024 * 1024) {
        return '${(byte / 1024 / 1024).toStringAsFixed(2)} MB';
      }
      return '${(byte / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }

    if (!syncState.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: NeoBrutalColors.violet,
          border: Border.all(width: 4, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: NeoBrutalColors.ink, size: 20),
            const SizedBox(width: 10),
            Text(
              l10n.bookSyncStatusNotSyncing.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: NeoBrutalColors.ink,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      );
    }

    final syncDirection = syncState.direction == SyncDirection.upload
        ? l10n.bookSyncStatusUploadingTitle
        : l10n.bookSyncStatusDownloadingTitle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalColors.yellow,
        border: Border.all(width: 4, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowSmall(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            syncDirection.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: NeoBrutalColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            syncState.fileName,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NeoBrutalColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value:
                syncState.total > 0 ? syncState.count / syncState.total : 0,
            backgroundColor: NeoBrutalColors.white,
            color: NeoBrutalColors.red,
            minHeight: 8,
          ),
          const SizedBox(height: 5),
          Text(
            '${byteToHuman(syncState.count)} / ${byteToHuman(syncState.total)}',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: NeoBrutalColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateTimeInfo(
    DateTime localTime,
    DateTime? lastUploadTime,
    L10n l10n,
  ) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    Widget buildTimeRow(String label, String time) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: NeoBrutalColors.ink,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: NeoBrutalColors.ink,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTimeRow(l10n.bookSyncStatusLocalUpdateTime,
            dateFormatter.format(localTime)),
        const SizedBox(height: 8),
        buildTimeRow(
          l10n.bookSyncStatusLastSyncTime,
          lastUploadTime != null
              ? dateFormatter.format(lastUploadTime)
              : l10n.bookSyncStatusNoSyncYet,
        ),
      ],
    );
  }

  List<BookSyncStatusEnum> _getBookDistributionStatus(
    bool showUploading,
    bool showChecking,
  ) {
    return [
      BookSyncStatusEnum.localOnly,
      BookSyncStatusEnum.remoteOnly,
      BookSyncStatusEnum.both,
      BookSyncStatusEnum.nonExistent,
      if (showUploading) BookSyncStatusEnum.uploading,
      if (showChecking) BookSyncStatusEnum.checking,
    ];
  }

  List<Color> _getBookDistributionColors() {
    return _getBookDistributionStatus(false, false)
        .map((e) => BookSyncStatusIcon(syncStatus: e).color)
        .toList();
  }

  Widget _buildBookDistributionChart(
    int localOnly,
    int remoteOnly,
    int both,
    int nonExistent,
  ) {
    final total = localOnly + remoteOnly + both + nonExistent;

    return LinearProportionBar(segments: [
      SegmentData(
        proportion: total > 0 ? localOnly / total : 0,
        color: _getBookDistributionColors()[0],
        showLabel: true,
      ),
      SegmentData(
        proportion: total > 0 ? remoteOnly / total : 0,
        color: _getBookDistributionColors()[1],
        showLabel: true,
      ),
      SegmentData(
        proportion: total > 0 ? both / total : 0,
        color: _getBookDistributionColors()[2],
        showLabel: true,
      ),
      SegmentData(
        proportion: total > 0 ? nonExistent / total : 0,
        color: _getBookDistributionColors()[3],
        showLabel: true,
      ),
    ]);
  }

  Widget _buildBookStats(
    int localOnly,
    int remoteOnly,
    int both,
    int nonExistent,
    L10n l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow(
            l10n.bookSyncStatusLocalOnlyBooks,
            l10n.bookSyncStatusBooksCount(localOnly),
            BookSyncStatusEnum.localOnly),
        const SizedBox(height: 6),
        _buildStatRow(
            l10n.bookSyncStatusRemoteOnlyBooks,
            l10n.bookSyncStatusBooksCount(remoteOnly),
            BookSyncStatusEnum.remoteOnly),
        const SizedBox(height: 6),
        _buildStatRow(
            l10n.bookSyncStatusBothBooks,
            l10n.bookSyncStatusBooksCount(both),
            BookSyncStatusEnum.both),
        const SizedBox(height: 6),
        _buildStatRow(
            l10n.bookSyncStatusNonExistentBooks,
            l10n.bookSyncStatusBooksCount(nonExistent),
            BookSyncStatusEnum.nonExistent),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    BookSyncStatusEnum syncStatus,
  ) {
    return Row(
      children: [
        BookSyncStatusIcon(syncStatus: syncStatus),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: NeoBrutalColors.ink,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: NeoBrutalColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
  ) {
    return Row(
      children: [
        // Download outline button — neo style
        _NeoActionButton(
          label: l10n.downloadAllBooks,
          icon: Icons.download_for_offline,
          color: NeoBrutalColors.white,
          textColor: NeoBrutalColors.ink,
          onPressed: () {
            final remoteOnlyIds = ref
                    .read(syncStatusProvider)
                    .whenData((data) => data.remoteOnly)
                    .value ??
                [];
            if (remoteOnlyIds.isNotEmpty) {
              ref
                  .read(syncProvider.notifier)
                  .downloadMultipleBooks(remoteOnlyIds);
              AnxToast.show('');
            } else {
              AnxToast.show(l10n.allBooksAreDownloaded);
            }
          },
        ),
        const SizedBox(width: 12),
        // Sync Now primary button — red neo style
        Expanded(
          child: _NeoActionButton(
            label: l10n.syncNow,
            icon: Icons.sync,
            color: NeoBrutalColors.red,
            textColor: NeoBrutalColors.white,
            onPressed: () {
              final isSyncing = ref.read(syncProvider).isSyncing;
              if (isSyncing) {
                AnxToast.show(l10n.webdavSyncing);
              } else {
                ref.read(syncProvider.notifier).syncData(
                    SyncDirection.both, ref,
                    trigger: SyncTrigger.manual);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Section label with yellow bar style
class _NeoSectionLabel extends StatelessWidget {
  const _NeoSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: NeoBrutalColors.yellow,
        border: Border(
          top: BorderSide(width: 4, color: NeoBrutalColors.ink),
          left: BorderSide(width: 4, color: NeoBrutalColors.ink),
          right: BorderSide(width: 4, color: NeoBrutalColors.ink),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.15,
          color: NeoBrutalColors.ink,
        ),
      ),
    );
  }
}

/// Neo-brutalist action button — push-effect, colored, sharp borders
class _NeoActionButton extends StatefulWidget {
  const _NeoActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  State<_NeoActionButton> createState() => _NeoActionButtonState();
}

class _NeoActionButtonState extends State<_NeoActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()
          ..translate(
            _isPressed ? 3.0 : 0.0,
            _isPressed ? 3.0 : 0.0,
          ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(width: 4, color: NeoBrutalColors.ink),
          boxShadow: _isPressed ? [] : NeoBrutalColors.hardShadowSmall(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.08,
                color: widget.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
