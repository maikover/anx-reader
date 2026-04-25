import 'package:cubebook/widgets/statistic/dashboard_tiles/dashboard_tile_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';

class DashboardTileDetailView extends ConsumerStatefulWidget {
  const DashboardTileDetailView({
    super.key,
    required this.tile,
    required this.heroTag,
    this.animationValue = 1.0,
  });

  final StatisticsDashboardTileBase tile;
  final String heroTag;
  final double animationValue;

  @override
  ConsumerState<DashboardTileDetailView> createState() =>
      _DashboardTileDetailViewState();
}

class _DashboardTileDetailViewState
    extends ConsumerState<DashboardTileDetailView> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final shouldDismiss = velocity.distance > 500 || _dragOffset.distance > 100;

    if (shouldDismiss) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid dark overlay (neo-brutalist - no blur)
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),

        // Draggable card
        AnimatedPositioned(
          duration:
              _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          left: MediaQuery.of(context).size.width / 2 -
              widget.tile.flipSize(context).width / 2 +
              _dragOffset.dx,
          top: MediaQuery.of(context).size.height / 2 -
              widget.tile.flipSize(context).height / 2 +
              _dragOffset.dy,
          child: GestureDetector(
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            child: Heroine(
              tag: widget.heroTag,
              child: widget.tile.buildFlipSide(context, ref),
            ),
          ),
        ),
      ],
    );
  }
}
