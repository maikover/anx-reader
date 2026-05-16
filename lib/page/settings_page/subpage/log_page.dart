import 'dart:io';

import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/save_file_to_download.dart';
import 'package:cubebook/utils/get_path/log_file.dart';
import 'package:cubebook/utils/toast/common.dart';
import 'package:cubebook/utils/log/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<String> logs = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    File logFile = await getLogFile();
    setState(() {
      logs = logFile.readAsLinesSync().reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: NeoBrutalColors.cardColor(isDark),
      appBar: AppBar(
        backgroundColor: NeoBrutalColors.cardColor(isDark),
        title: Text(
          L10n.of(context).settingsAdvancedLog,
          style: TextStyle(color: NeoBrutalColors.borderColor(isDark)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: NeoBrutalColors.borderColor(isDark)),
            onPressed: () {
              initData();
            },
          ),
          IconButton(
              onPressed: () => showMoreAction(context),
              icon: Icon(Icons.more_vert, color: NeoBrutalColors.borderColor(isDark))),
        ],
      ),
      body: ListView(
        children: [for (final log in logs) logItem(log, context)],
      ),
    );
  }

  void showMoreAction(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).padding.top + kToolbarHeight,
        0.0,
        0.0,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: Text(L10n.of(context).settingsAdvancedLogClearLog),
            onTap: () => clearLog(),
          ),
        ),
        PopupMenuItem(
            child: ListTile(
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(L10n.of(context).settingsAdvancedLogExportLog),
          onTap: () => exportLog(),
        ))
      ],
    );
  }

  Future<void> clearLog() async {
    Navigator.pop(context);
    AnxLog.clear();
    initData();
  }

  Future<void> exportLog() async {
    Navigator.pop(context);
    File logFile = await getLogFile();
    // SaveFileDialogParams params = SaveFileDialogParams(
    //   sourceFilePath: logFile.path,
    // );
    // await FlutterFileDialog.saveFile(params: params);
    String fileName =
        'Cubebook-Log-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.txt';
    String? filePath = await saveFileToDownload(
        bytes: await logFile.readAsBytes(),
        fileName: fileName,
        mimeType: 'text/plain');

    AnxToast.show("saved $filePath");
  }
}

Widget logItem(String logStr, BuildContext context) {
  final log = AnxLog.parse(logStr);
  return SelectionArea(
      child: Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
          decoration: BoxDecoration(
            color: log.color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(log.level.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        Text(log.time.toString()),
        const SizedBox(height: 5),
        Text(log.message),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: logStr));
              },
              child: Text(L10n.of(context).commonCopy),
            ),
          ],
        ),
        const Divider(),
      ],
    ),
  ));
}
