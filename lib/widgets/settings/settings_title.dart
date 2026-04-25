import 'package:cubebook/main.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/settings/settings_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget settingsTitle({
  required Icon icon,
  required String title,
  required bool isMobile,
  required int id,
  required int selectedIndex,
  required Function setDetail,
  required Widget subPage,
  required List<String> subtitle,
}) {
  BuildContext context = navigatorKey.currentContext!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isSelected = !isMobile && selectedIndex == id;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: isSelected ? NeoBrutalColors.adaptiveYellow(isDark) : NeoBrutalColors.cardColor(isDark),
        border: Border.all(
          width: isSelected ? 4 : 3,
          color: NeoBrutalColors.borderColor(isDark),
        ),
        boxShadow: isSelected
            ? NeoBrutalColors.adaptiveShadowSmall(isDark)
            : NeoBrutalColors.adaptiveShadowSmall(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isMobile) {
              setDetail(subPage, id);
              return;
            }
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => subPage),
            );
          },
          borderRadius: BorderRadius.zero,
          highlightColor: NeoBrutalColors.adaptiveYellow(isDark).withAlpha(80),
          splashColor: NeoBrutalColors.adaptiveYellow(isDark).withAlpha(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icon in colored bordered box
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NeoBrutalColors.adaptiveRed(isDark)
                        : (isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.cream),
                    border: Border.all(
                      width: 2.5,
                      color: NeoBrutalColors.borderColor(isDark),
                    ),
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: NeoBrutalColors.borderColor(isDark),
                        size: 18,
                      ),
                      child: icon,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: NeoBrutalColors.borderColor(isDark),
                          letterSpacing: 0.01,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle.join(' • '),
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: NeoBrutalColors.borderColor(isDark),
                            letterSpacing: 0.05,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_sharp,
                  color: NeoBrutalColors.borderColor(isDark),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget settingsSections({
  required List<AbstractSettingsSection> sections,
}) {
  return ListView.builder(
    itemCount: sections.length,
    itemBuilder: (context, index) {
      return sections[index];
    },
  );
}
