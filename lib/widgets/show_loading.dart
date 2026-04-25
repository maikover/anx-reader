import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/container/filled_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart'
    show SmartDialog;

void showLoading() {
  SmartDialog.show(
    builder: (context) => Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NeoBrutalColors.darkSurface
              : NeoBrutalColors.white,
          border: Border.all(width: 4, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowMedium(),
        ),
        child: CircularProgressIndicator(
          color: NeoBrutalColors.red,
          strokeWidth: 4,
        ),
      ),
    ),
  );
}