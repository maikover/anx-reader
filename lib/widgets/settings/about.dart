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
                 _NeoMenuItem(
                   title: L10n.of(context).appLicense,
                   icon: Icons.description,
                   onTap: () {
                     showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('MIT License'),
                         content: SingleChildScrollView(
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Text(
                                 'MIT License\n\n'
                                 'Copyright (c) 2025 Cubebook\n\n'
                                 'Permission is hereby granted, free of charge, to any person obtaining a copy\n'
                                 'of this software and associated documentation files (the "Software"), to deal\n'
                                 'in the Software without restriction, including without limitation the rights\n'
                                 'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n'
                                 'copies of the Software, and to permit persons to whom the Software is\n'
                                 'furnished to do so, subject to the following conditions:\n\n'
                                 'The above copyright notice and this permission notice shall be included in all\n'
                                 'copies or substantial portions of the Software.\n\n'
                                 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n'
                                 'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n'
                                 'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n'
                                 'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n'
                                 'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n'
                                 'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n'
                                 'SOFTWARE.',
                               ),
                               const SizedBox(height: 16),
                               TextButton.icon(
                                 onPressed: () {
                                   launchUrl(
                                     Uri.parse('https://github.com/cubebook/cubebook'),
                                     mode: LaunchMode.externalApplication,
                                   );
                                 },
                                 icon: const Icon(Icons.code, size: 16),
                                 label: const Text('View Repository'),
                               ),
                             ],
                           ),
                         ),
                         actions: [
                           TextButton(
                             onPressed: () => Navigator.pop(context),
                             child: const Text('OK'),
                           ),
                         ],
                       ),
                     );
                   },
                 ),
                 _NeoMenuItem(
                  title: L10n.of(context).aboutPrivacyPolicy,
                  icon: Icons.privacy_tip,
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://cube-book.vercel.app/en/privacy'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                 _NeoMenuItem(
                  title: 'Contacto',
                  icon: Icons.email_outlined,
                  onTap: () async {
                    launchUrl(
                      Uri.parse('mailto:contacto@arcaico.com.co'),
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
                         url: 'https://cube-book.vercel.app',
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
