import 'dart:math';

import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/main.dart';
import 'package:cubebook/providers/dashboard_tiles_provider.dart';
import 'package:cubebook/service/vibration_service.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/fitted_text.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_detail_view.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_metadata.dart';
import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';
import 'package:staggered_reorderable/staggered_reorderable.dart';

/// Base class for all statistics dashboard tiles.
abstract class StatisticsDashboardTileBase {
  const StatisticsDashboardTileBase();

  StatisticsDashboardTileMetadata get metadata;

  StatisticsDashboardTileType get type => metadata.type;

  /// Builds the tile body with access to BuildContext and WidgetRef.
  Widget buildContent(BuildContext context, WidgetRef ref);

  /// Called when the tile is removed from the dashboard.
  /// Override this method to perform cleanup or additional actions.
  void onRemove(BuildContext context, WidgetRef ref) {}

  /// Builds an optional icon widget for the tile.
  /// Override this method to provide a custom icon.
  Widget buildCorner(BuildContext context, WidgetRef ref) => SizedBox.shrink();

  L10n get l10nLocal => L10n.of(navigatorKey.currentContext!);

  Widget buildTile(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          width: 4,
          color: NeoBrutalColors.borderColor(isDark),
        ),
        boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: -0.2,
                child: buildCorner(context, ref),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                Expanded(
                  child: buildContent(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get title => '';

  bool get canFlip => true;

  double get flipSquareSize => 120;

  double get flipTitleSize => 100;

  Size tileSize(BuildContext context) {
    final width = min(flipSquareSize * metadata.columnSpan,
        MediaQuery.sizeOf(context).width * 0.9);
    final height = min(flipSquareSize * metadata.rowSpan,
        MediaQuery.sizeOf(context).height * 0.8);
    return Size(width, height);
  }

  Size flipSize(BuildContext context) {
    final width = min(max(flipSquareSize * metadata.columnSpan, 300.0),
        MediaQuery.sizeOf(context).width * 0.9);

    final height = min(flipSquareSize * metadata.rowSpan + flipTitleSize,
        MediaQuery.sizeOf(context).height * 0.8);

    return Size(width, height);
  }

  Widget buildFlipSide(BuildContext context, WidgetRef ref) {
    return flipScaffold(
      context,
      ref,
      buildTile(context, ref),
    );
  }

  void onTap(BuildContext context, WidgetRef ref) {}

  Widget cornerIcon(BuildContext context, IconData iconData) {
    return Icon(
      iconData,
      size: 90,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget cornerText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget flipScaffold(BuildContext context, WidgetRef ref, Widget flipContent) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final spacing = 8.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          width: 4,
          color: NeoBrutalColors.borderColor(isDark),
        ),
        boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
      ),
      width: flipSize(context).width,
      height: flipSize(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: flipTitleSize - spacing - 5,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  width: 4,
                  color: NeoBrutalColors.borderColor(isDark),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      metadata.icon,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedText(
                        metadata.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        maxHeight: 25,
                      ),
                    ),
                  ],
                ),
                Text(
                  metadata.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(12),
                    height: flipSquareSize * metadata.rowSpan -
                        12 * 2, // minus margin
                    child: flipContent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns the [ReorderableItem] used by the reorderable grid.
  ReorderableItem buildReorderableItem({required BuildContext context}) {
    return ReorderableItem(
      trackingNumber: type.index,
      id: type.name,
      crossAxisCellCount: metadata.columnSpan,
      mainAxisCellCount: metadata.rowSpan,
      child: DashboardTileShell(
        tileType: type,
        tile: this,
        buildContent: buildContent,
      ),
      placeholder: Opacity(
        opacity: 0.5,
        child: DashboardTileShell(
          tileType: type,
          tile: this,
          buildContent: buildContent,
        ),
      ),
    );
  }
}

class DashboardTileShell extends ConsumerWidget {
  const DashboardTileShell({
    super.key,
    required this.buildContent,
    required this.tileType,
    required this.tile,
  });

  final Widget Function(BuildContext context, WidgetRef ref) buildContent;
  final StatisticsDashboardTileType tileType;
  final StatisticsDashboardTileBase tile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardTilesProvider);
    final showRemoveButton = state.isEditing && state.workingTiles.length > 1;

    final notifier = ref.read(dashboardTilesProvider.notifier);
    final heroTag = 'dashboard_tile_${tileType.name}';

    return Heroine(
      tag: heroTag,
      flightShuttleBuilder: const FlipShuttleBuilder(
        axis: Axis.vertical,
        halfFlips: 1,
      ),
      motion: Motion.bouncySpring(
        snapToEnd: true,
        duration: const Duration(milliseconds: 500),
      ),
      child: GestureDetector(
        onTap: () {
          if (!tile.canFlip) {
            tile.onTap(context, ref);
            return;
          }
          VibrationService.medium();
          Navigator.of(context)
              .push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return DashboardTileDetailView(
                      tile: tile,
                      heroTag: heroTag,
                      animationValue: animation.value,
                    );
                  },
                );
              },
            ),
          )
              .then((_) {
            VibrationService.rigid();
          });
        },
        child: Stack(
          children: [
            tile.buildTile(context, ref),
            if (showRemoveButton)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  tooltip: L10n.of(context).commonRemove,
                  onPressed: () {
                    notifier.removeTile(tileType);
                    tile.onRemove(context, ref);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
