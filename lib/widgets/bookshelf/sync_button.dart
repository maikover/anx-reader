import 'package:cubebook/providers/sync.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/bookshelf/sync_status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncButton extends ConsumerStatefulWidget {
  const SyncButton({super.key});

  @override
  ConsumerState createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<SyncButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _syncAnimationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween(begin: 1.0, end: 0.0).animate(_syncAnimationController);
  }

  @override
  void dispose() {
    _syncAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(syncProvider.select((value) => value.isSyncing), (_, isSyncing) {
      if (isSyncing) {
        _syncAnimationController.repeat();
      } else {
        _syncAnimationController.stop();
      }
    });

    final isSyncing = ref.watch(syncProvider.select((s) => s.isSyncing));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        showSyncStatusBottomSheet(context);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: NeoBrutalColors.cardColor(isDark),
          border: Border.all(width: 3, color: NeoBrutalColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(offset: const Offset(4, 4), blurRadius: 0, color: NeoBrutalColors.borderColor(isDark)),
          ],
        ),
        child: Center(
          child: isSyncing
              ? RotationTransition(
                  turns: _animation,
                  child: Icon(
                    Icons.sync,
                    size: 22,
                    color: NeoBrutalColors.borderColor(isDark),
                  ),
                )
              : Icon(
                  Icons.sync,
                  size: 22,
                  color: NeoBrutalColors.borderColor(isDark),
                ),
        ),
      ),
    );
  }
}
