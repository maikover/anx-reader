import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/enums/sync_protocol.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/page/settings_page/sync.dart';
import 'package:cubebook/providers/sync.dart';
import 'package:cubebook/utils/webdav/test_webdav.dart';
import 'package:cubebook/widgets/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AbstractSettingsTile webdavSwitch(
    BuildContext context, Function setState, WidgetRef ref) {
  final isConfigured =
      Prefs().getSyncInfo(SyncProtocol.webdav)['url']?.isNotEmpty ?? false;

  return SettingsTile.switchTile(
    leading: const Icon(Icons.cached),
    trailing: Icon(
      Icons.chevron_right_sharp,
      color: Theme.of(context).iconTheme.color,
    ),
    initialValue: Prefs().webdavStatus,
    onToggle: (bool value) async {
      if (value && !isConfigured) {
        showWebdavDialog(context);
        return;
      }
      setState(() {
        Prefs().saveWebdavStatus(value);
      });
      if (value) {
        bool result = await testEnableWebdav();
        if (!result) {
          setState(() {
            Prefs().saveWebdavStatus(!value);
          });
        } else {
          Sync().init();
          chooseDirection(ref);
        }
      }
    },
    title: Text(L10n.of(context).settingsSyncEnableWebdav),
  );
}
