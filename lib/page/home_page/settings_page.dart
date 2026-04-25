import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/page/iap_page.dart';
import 'package:cubebook/page/settings_page/more_settings_page.dart';
import 'package:cubebook/providers/iap.dart';
import 'package:cubebook/service/iap/iap_service.dart';
import 'package:cubebook/utils/env_var.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/neo/cube_book_logo.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:cubebook/widgets/settings/about.dart';
import 'package:cubebook/widgets/settings/theme_mode.dart';
import 'package:cubebook/widgets/settings/webdav_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, this.controller});

  final ScrollController? controller;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final ScrollController _scrollController =
      widget.controller ?? ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeoBackground(
      pattern: NeoBackgroundPattern.grid,
      opacity: 0.03,
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Neo-brutalist logo with colored letters
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 30),
                    child: const CubeBookLogoPop(fontSize: 48),
                  ),
                ),

                // Thick divider
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: NeoBrutalColors.borderColor(isDark),
                ),

                // Theme mode selector with Neo styling
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.cardColor(isDark),
                      border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                      boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                    ),
                    child: const ChangeThemeMode(),
                  ),
                ),

                // Thick divider
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: NeoBrutalColors.borderColor(isDark),
                ),

                // WebDAV switch
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.cardColor(isDark),
                      border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                      boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                    ),
                    child: webdavSwitch(context, setState, ref),
                  ),
                ),

                // Thick divider
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: NeoBrutalColors.borderColor(isDark),
                ),

                // More settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.cardColor(isDark),
                      border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                      boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                    ),
                    child: const MoreSettings(),
                  ),
                ),

                // IAP if enabled
                if (EnvVar.enableInAppPurchase)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeoBrutalColors.cardColor(isDark),
                        border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                        boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NeoBrutalColors.adaptiveYellow(isDark),
                            border: Border.all(
                                width: 3, color: NeoBrutalColors.borderColor(isDark)),
                          ),
                          child: Icon(
                            Icons.star_outline,
                            color: NeoBrutalColors.borderColor(isDark),
                          ),
                        ),
                        title: Text(
                          L10n.of(context).iapPageTitle,
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w700,
                            color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          ref.watch(iapProvider).maybeWhen(
                                data: (state) => state.status.title(context),
                                orElse: () => L10n.of(context).iapStatusUnknown,
                              ),
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w700,
                            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(width: 2, color: NeoBrutalColors.borderColor(isDark)),
                          ),
                          child: Icon(Icons.chevron_right, color: NeoBrutalColors.borderColor(isDark)),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const IAPPage()));
                        },
                      ),
                    ),
                  ),

                // About section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NeoBrutalColors.cardColor(isDark),
                      border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                      boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                    ),
                    child: const About(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}