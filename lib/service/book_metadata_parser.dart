import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

Future<Map<String, dynamic>> parseEpubMetadata(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile == null) throw Exception('Not a valid EPUB: missing container.xml');

    final containerContent = utf8.decode(containerFile.content as List<int>);
    final opfMatch = RegExp(r'full-path="([^"]+)"').firstMatch(containerContent);
    if (opfMatch == null) throw Exception('No OPF file found in container.xml');

    final opfPath = opfMatch.group(1)!;
    final opfFile = archive.findFile(opfPath);
    if (opfFile == null) throw Exception('OPF file not found: $opfPath');

    final opfContent = utf8.decode(opfFile.content as List<int>);

    String title = _extractTag(opfContent, 'title');
    if (title.isEmpty) title = 'Unknown';

    final authorMatches = RegExp(r'<dc:creator[^>]*>(.*?)</dc:creator>', caseSensitive: false, dotAll: true).allMatches(opfContent);
    String author = authorMatches.isNotEmpty 
        ? authorMatches.map((m) => m.group(1)?.trim() ?? '').where((s) => s.isNotEmpty).join(', ')
        : 'Unknown';

    String description = _extractTag(opfContent, 'description');
    // Remove html tags from description if any
    description = description.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    // Cover
    String coverBase64 = '';
    String? coverHref;

    // 1. Check meta name="cover" content="id"
    final metaCoverMatch = RegExp(r'<meta[^>]*name="cover"[^>]*content="([^"]+)"[^>]*>', caseSensitive: false).firstMatch(opfContent) ?? 
                           RegExp(r'<meta[^>]*content="([^"]+)"[^>]*name="cover"[^>]*>', caseSensitive: false).firstMatch(opfContent);
                           
    if (metaCoverMatch != null) {
      final coverId = metaCoverMatch.group(1)!;
      final itemMatch = RegExp('<item[^>]*id="$coverId"[^>]*href="([^"]+)"[^>]*>', caseSensitive: false).firstMatch(opfContent) ??
                        RegExp('<item[^>]*href="([^"]+)"[^>]*id="$coverId"[^>]*>', caseSensitive: false).firstMatch(opfContent);
      if (itemMatch != null) coverHref = itemMatch.group(1);
    }

    // 2. Check item properties="cover-image"
    if (coverHref == null) {
      final itemMatch = RegExp(r'<item[^>]*properties="cover-image"[^>]*href="([^"]+)"[^>]*>', caseSensitive: false).firstMatch(opfContent) ??
                        RegExp(r'<item[^>]*href="([^"]+)"[^>]*properties="cover-image"[^>]*>', caseSensitive: false).firstMatch(opfContent);
      if (itemMatch != null) coverHref = itemMatch.group(1);
    }
    
    // 3. Fallback: item id="cover"
    if (coverHref == null) {
      final itemMatch = RegExp(r'<item[^>]*id="cover"[^>]*href="([^"]+)"[^>]*>', caseSensitive: false).firstMatch(opfContent) ??
                        RegExp(r'<item[^>]*href="([^"]+)"[^>]*id="cover"[^>]*>', caseSensitive: false).firstMatch(opfContent);
      if (itemMatch != null) coverHref = itemMatch.group(1);
    }

    if (coverHref != null) {
      final opfDir = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/')) : '';
      String fullCoverPath = opfDir.isEmpty ? coverHref : '$opfDir/$coverHref';
      fullCoverPath = Uri.decodeComponent(fullCoverPath);
      
      final coverFile = archive.findFile(fullCoverPath);
      if (coverFile != null) {
        final coverBytes = coverFile.content as List<int>;
        final ext = fullCoverPath.split('.').last.toLowerCase();
        final mediaType = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
        coverBase64 = 'data:$mediaType;base64,${base64Encode(coverBytes)}';
      }
    }

    return {
      'title': title,
      'author': author,
      'description': description,
      'cover': coverBase64,
    };
  } catch (e) {
    return {
      'title': 'Unknown',
      'author': 'Unknown',
      'description': '',
      'cover': '',
    };
  }
}

String _extractTag(String xml, String tag) {
  final match = RegExp('<dc:$tag[^>]*>(.*?)</dc:$tag>', caseSensitive: false, dotAll: true).firstMatch(xml);
  return match?.group(1)?.trim() ?? '';
}
