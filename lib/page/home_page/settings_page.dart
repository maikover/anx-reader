import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/page/iap_page.dart';
import 'package:cubebook/page/settings_page/more_settings_page.dart';
import 'package:cubebook/providers/iap.dart';
import 'package:cubebook/service/iap/iap_service.dart';
import 'package:cubebook/utils/env_var.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: Text(
                        'CubeBook',
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 10, 8),
                child: ChangeThemeMode(),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: webdavSwitch(context, setState, ref),
              ),
              const Divider(),
              const MoreSettings(),
              if (EnvVar.enableInAppPurchase)
                ListTile(
                  title: Text(L10n.of(context).iapPageTitle),
                  leading: const Icon(Icons.star_outline),
                  subtitle: Text(ref.watch(iapProvider).maybeWhen(
                        data: (state) => state.status.title(context),
                        orElse: () => L10n.of(context).iapStatusUnknown,
                      )),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const IAPPage()));
                  },
                ),
              const About(),
            ],
          ),
        ),
      ),
    );
  }
}
