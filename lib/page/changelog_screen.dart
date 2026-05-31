import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/utils/get_current_language_code.dart';
import 'package:cubebook/utils/log/common.dart';
import 'package:cubebook/widgets/markdown/styled_markdown.dart';
import 'package:cubebook/widgets/neo/neo_primitives.dart';
import 'package:cubebook/widgets/neo/neo_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Changelog screen for showing app updates
/// Displays version history and new features
class ChangelogScreen extends StatefulWidget {
  final String lastVersion;
  final String currentVersion;
  final VoidCallback onComplete;

  const ChangelogScreen({
    super.key,
    required this.lastVersion,
    required this.currentVersion,
    required this.onComplete,
  });

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  String _changelogContent = '';
  bool _isLoading = true;

  String get currentVersion => widget.currentVersion.split('+').first;
  String get lastVersion => widget.lastVersion.split('+').first;

  @override
  void initState() {
    super.initState();
    _loadChangelog();
  }

  Future<void> _loadChangelog() async {
    try {
      // Load changelog from assets
      final String fullChangelog =
          await rootBundle.loadString('assets/CHANGELOG.md');
      _changelogContent = _extractVersionChangelog(fullChangelog);
    } catch (e) {
      AnxLog.warning('Failed to load changelog from assets: $e');
      _changelogContent = _getDefaultChangelog();
    } finally {
      _changelogContent = processChangelogContent(_changelogContent);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String processChangelogContent(String content) {
    bool isChinese() => getCurrentLanguageCode().startsWith('zh');

    final lines = content.split('\n');
    var processedLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('* ')) {
        processedLines.add(line);
        continue;
      }
    }
    if (isChinese()) {
      processedLines = processedLines.sublist(processedLines.length ~/ 2);
    } else {
      processedLines = processedLines.sublist(0, processedLines.length ~/ 2);
    }

    return processedLines.join('\n');
  }

  String _extractVersionChangelog(String fullChangelog) {
    // Extract version number from currentVersion (e.g., "1.2.3+1234" -> "1.2.3")
    final versionMatch = RegExp(r'^(\d+\.\d+\.\d+)').firstMatch(currentVersion);
    if (versionMatch == null) {
      return _getDefaultChangelog();
    }

    final version = versionMatch.group(1)!;
    final versionHeader = '## $version';

    // Find the version section in the changelog
    final lines = fullChangelog.split('\n');
    final startIndex = lines.indexWhere((line) => line.trim() == versionHeader);

    if (startIndex == -1) {
      AnxLog.warning('Version $version not found in changelog');
      return _getDefaultChangelog();
    }

    // Find the end of this version section (next version header or end of file)
    int endIndex = lines.length;
    for (int i = startIndex + 1; i < lines.length; i++) {
      if (lines[i].trim().startsWith('## ') &&
          lines[i].trim() != versionHeader) {
        endIndex = i;
        break;
      }
    }

    // Extract the content for this version (skip the header line)
    final versionContent =
        lines.sublist(startIndex + 1, endIndex).join('\n').trim();

    if (versionContent.isEmpty) {
      return _getDefaultChangelog();
    }

    return versionContent;
  }

  String _getDefaultChangelog() {
    return '''
- Fixed some bugs
- 修复已知问题
''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeoScaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).whatsNew),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: NeoContainer(
                    width: double.infinity,
                    color: NeoBrutalColors.adaptiveYellow(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              color: NeoBrutalColors.borderColor(isDark),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              L10n.of(context).updateFromVersion(lastVersion),
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: NeoBrutalColors.borderColor(isDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          L10n.of(context).welcomeToVersion(currentVersion),
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: NeoBrutalColors.borderColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NeoContainer(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: StyledMarkdown(data: _changelogContent),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: NeoButton(
                      onPressed: _onComplete,
                      variant: NeoButtonVariant.primary,
                      fullWidth: true,
                      child: Text(L10n.of(context).commonOk.toUpperCase()),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _onComplete() async {
    widget.onComplete();
  }
}
