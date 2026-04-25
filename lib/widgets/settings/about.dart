import 'dart:async';

import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/main.dart';
import 'package:cubebook/page/settings_page/developer/developer_options_page.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/env_var.dart';
import 'package:cubebook/utils/toast/common.dart';
import 'package:cubebook/widgets/common/container/filled_container.dart';
import 'package:cubebook/widgets/neo/cube_book_logo.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:cubebook/widgets/settings/show_donate_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({
    super.key,
    this.leadingColor = false,
  });
  final bool leadingColor;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String version = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(L10n.of(context).appAbout),
      leading: Icon(Icons.info_outline,
          color: widget.leadingColor
              ? Theme.of(context).colorScheme.primary
              : null),
      onTap: () => openAboutDialog(),
    );
  }
}

const int _developerUnlockTapThreshold = 7;
int _developerUnlockTapCount = 0;
Timer? _developerUnlockResetTimer;

void _handleDeveloperUnlockTap(BuildContext context) {
  _developerUnlockTapCount++;
  _developerUnlockResetTimer?.cancel();
  _developerUnlockResetTimer =
      Timer(const Duration(seconds: 2), () => _developerUnlockTapCount = 0);

  final alreadyEnabled = Prefs().developerOptionsEnabled;
  if (_developerUnlockTapCount < _developerUnlockTapThreshold) {
    return;
  }

  _developerUnlockTapCount = 0;
  if (!alreadyEnabled) {
    Prefs().developerOptionsEnabled = true;
    AnxToast.show('Developer options enabled');
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop();
  }
  Future.microtask(_openDeveloperOptionsPage);
}

void _openDeveloperOptionsPage() {
  final BuildContext? navContext = navigatorKey.currentContext;
  if (navContext == null) return;
  Navigator.of(navContext).push(
    CupertinoPageRoute(
      fullscreenDialog: false,
      builder: (context) => const DeveloperOptionsPage(),
    ),
  );
}

Future<void> openAboutDialog() async {
  final pubspecContent = await rootBundle.loadString('pubspec.yaml');
  final pubspec = Pubspec.parse(pubspecContent);
  final version = pubspec.version.toString();

  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: FilledContainer(
          radius: 0,
          constraints: const BoxConstraints(
            maxWidth: 500,
            minWidth: 300,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NeoBrutalColors.white,
                        border: Border.all(width: 3, color: NeoBrutalColors.ink),
                      ),
                      child: const CubeBookLogo(fontSize: 40),
                    ),
                  ),
                ),
                const NeoSectionDivider(),
                // Menu items
                _NeoMenuItem(
                  title: L10n.of(context).appVersion,
                  subtitle: version + (kDebugMode ? ' (debug)' : ''),
                  icon: Icons.info_outline,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: version));
                    AnxToast.show(L10n.of(context).notesPageCopied);
                    _handleDeveloperUnlockTap(context);
                  },
                ),
                if (EnvVar.enableDonation)
                  _NeoMenuItem(
                    title: L10n.of(context).appDonate,
                    icon: Icons.volunteer_activism,
                    onTap: () {
                      showDonateDialog(context);
                    },
                  ),
                _NeoMenuItem(
                  title: L10n.of(context).appLicense,
                  icon: Icons.description,
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'CubeBook',
                      applicationVersion: version,
                    );
                  },
                ),
                _NeoMenuItem(
                  title: L10n.of(context).appAuthor,
                  icon: EvaIcons.people,
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                          'https://github.com/Anxcye/anx-reader/graphs/contributors'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                _NeoMenuItem(
                  title: L10n.of(context).aboutPrivacyPolicy,
                  icon: Icons.privacy_tip,
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://anx.anxcye.com/privacy'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                _NeoMenuItem(
                  title: L10n.of(context).aboutTermsOfUse,
                  icon: Icons.article,
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://anx.anxcye.com/terms'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                _NeoMenuItem(
                  title: L10n.of(context).aboutHelp,
                  icon: Icons.help,
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://anx.anxcye.com/docs'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const NeoSectionDivider(),
                if (EnvVar.showBeian) ...[
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse('https://beian.miit.gov.cn/'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        '闽ICP备2025091402号-1A',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const NeoSectionDivider(),
                ],
                // Social links
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NeoLinkButton(
                        icon: Icon(
                          IonIcons.earth,
                          color: NeoBrutalColors.ink,
                        ),
                        url: 'https://anx.anxcye.com',
                      ),
                      const SizedBox(width: 8),
                      _NeoLinkButton(
                        icon: Icon(
                          IonIcons.logo_github,
                          color: NeoBrutalColors.ink,
                        ),
                        url: 'https://github.com/Anxcye/anx-reader',
                      ),
                      if (EnvVar.showTelegramLink) ...[
                        const SizedBox(width: 8),
                        _NeoLinkButton(
                          icon: Icon(
                            Icons.telegram,
                            color: NeoBrutalColors.ink,
                          ),
                          url: 'https://t.me/AnxReader',
                        ),
                      ],
                      const SizedBox(width: 8),
                      _NeoLinkButton(
                        icon: Image.asset(
                          'assets/images/xiaohongshu.png',
                          color: NeoBrutalColors.ink,
                        ),
                        url: 'https://www.xiaohongshu.com/user/profile/5d403f3e00000000100151ff',
                      ),
                      const SizedBox(width: 8),
                      _NeoLinkButton(
                        icon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/qq.png',
                            color: NeoBrutalColors.ink,
                          ),
                        ),
                        url: 'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=8BYItJOMz4RCQJoHAAei7FV-nGB0iT8O&authKey=MD6a7gI%2FENiMr32rQRTLx2BpzTaa1wO9Qfmhx9ETcaLS%2FdcOFeptvVH9FWfvUpL2&noverify=0&group_code=1042905699',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Neo-brutalist menu item for the about dialog
class _NeoMenuItem extends StatefulWidget {
  const _NeoMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_NeoMenuItem> createState() => _NeoMenuItemState();
}

class _NeoMenuItemState extends State<_NeoMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isPressed ? NeoBrutalColors.yellow : NeoBrutalColors.white,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    offset: Offset(3, 3),
                    blurRadius: 0,
                    color: NeoBrutalColors.ink,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NeoBrutalColors.yellow,
                border: Border.all(width: 2, color: NeoBrutalColors.ink),
              ),
              child: Icon(widget.icon, size: 20, color: NeoBrutalColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NeoBrutalColors.ink,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 12,
                        color: NeoBrutalColors.ink.withAlpha(180),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: NeoBrutalColors.ink,
            ),
          ],
        ),
      ),
    );
  }
}

/// Neo-brutalist link button for social icons
class _NeoLinkButton extends StatefulWidget {
  const _NeoLinkButton({
    required this.icon,
    required this.url,
  });

  final Widget icon;
  final String url;

  @override
  State<_NeoLinkButton> createState() => _NeoLinkButtonState();
}

class _NeoLinkButtonState extends State<_NeoLinkButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 44,
        height: 44,
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalColors.white,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    offset: Offset(3, 3),
                    blurRadius: 0,
                    color: NeoBrutalColors.ink,
                  ),
                ],
        ),
        child: Center(child: widget.icon),
      ),
    );
  }
}
