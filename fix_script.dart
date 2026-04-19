import 'dart:io';

void main() async {
  final analysisFile = File('analysis.txt');
  if (!analysisFile.existsSync()) {
    print('analysis.txt not found.');
    return;
  }
  
  final lines = await analysisFile.readAsLines();
  final editsByFile = <String, Set<int>>{};
  
  // Ex: error - lib/config/shared_preference_provider.dart:139:40 - The getter 'valueOrNull' isn't defined...
  // Ex: error - lib/page/settings_page/ai.dart:369:25 - The named parameter 'value' isn't defined...
  final regex = RegExp(r"^\s*error\s*-\s*([^:]+):(\d+):\d+\s*-\s*.*(?:valueOrNull|'value').*$");
  
  for (final line in lines) {
    if (!line.contains('valueOrNull') && !line.contains("'value'")) continue;
    final match = regex.firstMatch(line);
    if (match != null) {
      // Normalize slashes for windows paths just in case
      final file = match.group(1)!.trim(); 
      final lineNum = int.parse(match.group(2)!);
      editsByFile.putIfAbsent(file, () => {}).add(lineNum);
    }
  }

  int totalFixes = 0;
  for (final entry in editsByFile.entries) {
    final filePath = entry.key;
    final file = File(filePath);
    if (!file.existsSync()) {
      print('File not found: $filePath');
      continue;
    }
    
    final fileLines = file.readAsLinesSync();
    final sortedEdits = entry.value.toList()..sort();
    
    for (final lineNum in sortedEdits) {
      final index = lineNum - 1;
      if (index >= 0 && index < fileLines.length) {
        final original = fileLines[index];
        final modified = original.replaceAll('valueOrNull', 'value');
        if (original != modified) {
            fileLines[index] = modified;
            totalFixes++;
        }
      }
    }
    
    file.writeAsStringSync(fileLines.join('\n') + '\n');
    print('Fixed $filePath');
  }
  print('Total valueOrNull->value replacements: $totalFixes');
}
