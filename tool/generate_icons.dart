// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

// ---------------------------------------------------------------------------
// Dart reserved / built-in keywords – names that clash get an `icon_` prefix.
// ---------------------------------------------------------------------------
const _dartKeywords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

// Attributes on the root <svg> that we propagate into the root element map.
const _keepRootAttrs = <String>{
  'viewBox',
  'fill',
  'stroke',
  'stroke-width',
  'stroke-linecap',
  'stroke-linejoin',
};

// ---------------------------------------------------------------------------
// Family configuration
// ---------------------------------------------------------------------------
class IconFamily {
  const IconFamily({
    required this.key,
    required this.repoUrl,
    required this.branch,
    required this.className,
    required this.libraryName,
    required this.familyTag,
    required this.hasRoot,
    this.licenseHeader,
  });

  final String key;
  final String repoUrl;
  final String branch;
  final String className;
  final String libraryName;
  final String familyTag;
  final bool hasRoot;
  final String? licenseHeader;

  String get cloneDir => '/tmp/docudart-icons/$key';
  String get outputFile {
    if (key == 'lucide') return 'lucide_icons.dart';
    if (key == 'material-icons') return 'material_icons.dart';
    if (key == 'material-symbols') return 'material_symbols.dart';
    if (key == 'font-awesome') return 'font_awesome_icons.dart';
    return '${key.replaceAll('-', '_')}_icons.dart';
  }
}

const _families = <IconFamily>[
  IconFamily(
    key: 'lucide',
    repoUrl: 'https://github.com/lucide-icons/lucide',
    branch: 'main',
    className: 'LucideIcons',
    libraryName: 'Lucide',
    familyTag: 'lucide',
    hasRoot: true,
  ),
  IconFamily(
    key: 'material-icons',
    repoUrl: 'https://github.com/material-icons/material-icons',
    branch: 'master',
    className: 'MaterialIcons',
    libraryName: 'Material',
    familyTag: '',
    hasRoot: false,
    licenseHeader: '''// GENERATED CODE - DO NOT MODIFY BY HAND
// This file contains a collection of icons that are derived from the
// Material Design Icons by Google.
//
// The original icons are licensed under the Apache License, Version 2.0.
// Your use of these icons is subject to the terms and conditions of that license.
// For details, see the NOTICE file in this package.
''',
  ),
  IconFamily(
    key: 'material-symbols',
    repoUrl: 'https://github.com/marella/material-symbols',
    branch: 'main',
    className: 'MaterialSymbols',
    libraryName: 'Material Symbols',
    familyTag: 'material_symbols',
    hasRoot: true,
  ),
  IconFamily(
    key: 'tabler',
    repoUrl: 'https://github.com/tabler/tabler-icons',
    branch: 'main',
    className: 'TablerIcons',
    libraryName: 'Tabler',
    familyTag: 'tabler',
    hasRoot: true,
  ),
  IconFamily(
    key: 'fluent',
    repoUrl: 'https://github.com/microsoft/fluentui-system-icons',
    branch: 'main',
    className: 'FluentIcons',
    libraryName: 'Microsoft Fluent UI System',
    familyTag: 'fluent',
    hasRoot: true,
  ),
  IconFamily(
    key: 'font-awesome',
    repoUrl: 'https://github.com/FortAwesome/Font-Awesome',
    branch: '7.x',
    className: 'FontAwesomeIcons',
    libraryName: 'Font Awesome',
    familyTag: 'font_awesome',
    hasRoot: true,
  ),
  IconFamily(
    key: 'remix',
    repoUrl: 'https://github.com/Remix-Design/RemixIcon',
    branch: 'master',
    className: 'RemixIcons',
    libraryName: 'Remix',
    familyTag: 'remix',
    hasRoot: true,
  ),
];

// ---------------------------------------------------------------------------
// Parsed icon entry
// ---------------------------------------------------------------------------
class IconEntry {
  IconEntry({
    required this.name,
    required this.content,
    required this.previewSvg,
  });

  final String name;
  final List<Map<String, dynamic>> content;
  final String previewSvg;

  String get base64Preview => base64Encode(utf8.encode(previewSvg));
  String get altText => name.replaceAll('_', ' ');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
Future<void> main(List<String> args) async {
  final selectedFamilies = args.isEmpty
      ? _families
      : _families.where((f) => args.contains(f.key)).toList();

  if (selectedFamilies.isEmpty) {
    print(
      'Unknown family. Available: ${_families.map((f) => f.key).join(', ')}',
    );
    exit(1);
  }

  final iconsDir = '${Directory.current.path}/lib/src/icons';

  for (final family in selectedFamilies) {
    final IconFamily(:libraryName, :key, :outputFile) = family;
    print('\n${'=' * 60}');
    print('Processing: $libraryName ($key)');
    print('=' * 60);

    await _cloneOrUpdate(family);
    final icons = _discoverAndParse(family);
    icons.sort((a, b) => a.name.compareTo(b.name));

    // Deduplicate — keep first occurrence of each name
    final seen = <String>{};
    final deduped = <IconEntry>[];
    for (final icon in icons) {
      if (seen.add(icon.name)) {
        deduped.add(icon);
      }
    }
    if (deduped.length < icons.length) {
      print('  Removed ${icons.length - deduped.length} duplicate names');
    }
    print('  Generating ${deduped.length} icons → $outputFile');
    _writeDartFile(family, deduped, iconsDir);
  }

  print('\nDone!');
}

// ---------------------------------------------------------------------------
// Git clone / update
// ---------------------------------------------------------------------------
Future<void> _cloneOrUpdate(IconFamily family) async {
  final IconFamily(:cloneDir, :repoUrl, :branch) = family;
  final dir = Directory(cloneDir);
  if (dir.existsSync()) {
    print('  Updating existing clone at $cloneDir...');
    final result = Process.runSync('git', ['pull'], workingDirectory: cloneDir);
    if (result.exitCode != 0) {
      print('  Warning: git pull failed, using existing clone');
      print('  ${result.stderr}');
    }
  } else {
    print('  Cloning $repoUrl (branch: $branch)...');
    final result = Process.runSync('git', [
      'clone',
      '--depth',
      '1',
      '--branch',
      branch,
      repoUrl,
      cloneDir,
    ]);
    if (result.exitCode != 0) {
      print('  Error: git clone failed');
      print('  ${result.stderr}');
      exit(1);
    }
  }
}

// ---------------------------------------------------------------------------
// SVG discovery & parsing (dispatches per family)
// ---------------------------------------------------------------------------
List<IconEntry> _discoverAndParse(IconFamily family) {
  switch (family.key) {
    case 'lucide':
      return _parseLucide(family);
    case 'material-icons':
      return _parseMaterialIcons(family);
    case 'material-symbols':
      return _parseMaterialSymbols(family);
    case 'tabler':
      return _parseTabler(family);
    case 'fluent':
      return _parseFluent(family);
    case 'font-awesome':
      return _parseFontAwesome(family);
    case 'remix':
      return _parseRemixIcon(family);
    default:
      throw StateError('Unknown family: ${family.key}');
  }
}

// ---------------------------------------------------------------------------
// Lucide
// ---------------------------------------------------------------------------
List<IconEntry> _parseLucide(IconFamily family) {
  final svgDir = Directory('${family.cloneDir}/icons');
  final files = svgDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.svg'))
      .toList();
  print('  Found ${files.length} SVG files');

  final icons = <IconEntry>[];
  for (final file in files) {
    final filename = _basename(file.path);
    final baseName = filename.replaceAll('.svg', '');
    final dartName = _toDartName(baseName);

    final svgString = file.readAsStringSync();
    final doc = XmlDocument.parse(svgString);
    final svgElement = doc.rootElement;

    final rootAttrs = _extractRootAttrs(svgElement);
    final children = _extractChildren(svgElement);

    final content = <Map<String, dynamic>>[
      {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
      ...children,
    ];

    final preview = _makePreview(svgString, isStroke: true);
    icons.add(IconEntry(name: dartName, content: content, previewSvg: preview));
  }
  return icons;
}

// ---------------------------------------------------------------------------
// Material Icons (community mirror)
// ---------------------------------------------------------------------------
List<IconEntry> _parseMaterialIcons(IconFamily family) {
  final svgDir = Directory('${family.cloneDir}/svg');
  if (!svgDir.existsSync()) {
    print('  Error: svg/ directory not found in ${family.cloneDir}');
    return [];
  }

  final styleMap = {
    'baseline': '',
    'outline': '_outlined',
    'round': '_rounded',
    'sharp': '_sharp',
    'twotone': '_twotone',
  };

  final icons = <IconEntry>[];
  final iconDirs = svgDir.listSync().whereType<Directory>().toList();
  print('  Found ${iconDirs.length} icon directories');

  for (final iconDir in iconDirs) {
    final iconName = _basename(iconDir.path);
    for (final entry in styleMap.entries) {
      final styleFile = File('${iconDir.path}/${entry.key}.svg');
      if (!styleFile.existsSync()) continue;

      final baseDartName = _toDartName(iconName);
      final dartName = '$baseDartName${entry.value}';

      final svgString = styleFile.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;
      final children = _extractChildren(svgElement);

      // Material Icons: NO root element
      final content = <Map<String, dynamic>>[...children];

      final preview = _makePreview(svgString, isStroke: false);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  return icons;
}

// ---------------------------------------------------------------------------
// Material Symbols (marella mirror)
// ---------------------------------------------------------------------------
List<IconEntry> _parseMaterialSymbols(IconFamily family) {
  // Styles: outlined (default), rounded, sharp — each has normal + -fill variants
  final styleDirs = <String, String>{
    'outlined': '',
    'rounded': '_rounded',
    'sharp': '_sharp',
  };

  final icons = <IconEntry>[];
  int totalFiles = 0;

  for (final entry in styleDirs.entries) {
    final dirPath = '${family.cloneDir}/svg/400/${entry.key}';
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      print('  Warning: $dirPath not found, skipping');
      continue;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    totalFiles += files.length;

    for (final file in files) {
      final filename = _basename(file.path);
      final isFilled = filename.endsWith('-fill.svg');

      String baseName = filename.replaceAll('.svg', '');
      if (isFilled) baseName = baseName.replaceAll(RegExp(r'-fill$'), '');

      // Convert to snake_case (hyphens → underscores)
      baseName = baseName.replaceAll('-', '_');

      String dartName = _toDartName(baseName);

      // Apply style suffix
      final styleSuffix = entry.value;
      final fillSuffix = isFilled ? '_filled' : '';
      dartName = '$dartName$styleSuffix$fillSuffix';

      final svgString = file.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      final rootAttrs = _extractRootAttrs(svgElement);
      final children = _extractChildren(svgElement);

      final content = <Map<String, dynamic>>[
        {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
        ...children,
      ];

      final preview = _makePreview(svgString, isStroke: false);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  print('  Found $totalFiles SVG files');
  return icons;
}

// ---------------------------------------------------------------------------
// Tabler
// ---------------------------------------------------------------------------
List<IconEntry> _parseTabler(IconFamily family) {
  final styleDirs = <String, String>{'outline': '', 'filled': '_filled'};

  final icons = <IconEntry>[];
  int totalFiles = 0;

  for (final entry in styleDirs.entries) {
    final dirPath = '${family.cloneDir}/icons/${entry.key}';
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      print('  Warning: $dirPath not found, skipping');
      continue;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    totalFiles += files.length;

    final isOutline = entry.key == 'outline';

    for (final file in files) {
      final filename = _basename(file.path);
      final baseName = filename.replaceAll('.svg', '');
      String dartName = _toDartName(baseName);
      dartName = '$dartName${entry.value}';

      final svgString = file.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      final rootAttrs = _extractRootAttrs(svgElement);
      final children = _extractChildren(svgElement);

      final content = <Map<String, dynamic>>[
        {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
        ...children,
      ];

      final preview = _makePreview(svgString, isStroke: isOutline);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  print('  Found $totalFiles SVG files');
  return icons;
}

// ---------------------------------------------------------------------------
// Fluent UI System Icons
// ---------------------------------------------------------------------------
List<IconEntry> _parseFluent(IconFamily family) {
  final assetsDir = Directory('${family.cloneDir}/assets');
  if (!assetsDir.existsSync()) {
    print('  Error: assets/ directory not found');
    return [];
  }

  final icons = <IconEntry>[];
  int totalFiles = 0;

  // Walk all icon subdirectories
  final iconDirs = assetsDir.listSync().whereType<Directory>().toList();
  for (final iconDir in iconDirs) {
    final svgDir = Directory('${iconDir.path}/SVG');
    if (!svgDir.existsSync()) continue;

    final files = svgDir.listSync().whereType<File>().where((f) {
      final name = _basename(f.path);
      return name.endsWith('.svg') && name.contains('_24_');
    }).toList();
    totalFiles += files.length;

    for (final file in files) {
      final filename = _basename(file.path);
      // e.g. ic_fluent_access_time_24_filled.svg → access_time_filled
      String name = filename.replaceAll('.svg', '');

      // Remove ic_fluent_ prefix if present
      name = name.replaceFirst(RegExp(r'^ic_fluent_'), '');

      // Extract style from the part after _24_
      final match24 = RegExp(r'_24_(\w+)$').firstMatch(name);
      if (match24 == null) continue;
      final style = match24.group(1)!;
      // Remove _24_style from name
      name = name.substring(0, match24.start);

      // Apply suffix based on style
      String suffix;
      switch (style) {
        case 'regular':
          suffix = ''; // base style
          break;
        case 'filled':
          suffix = '_filled';
          break;
        case 'color':
          suffix = '_color';
          break;
        default:
          suffix = '_$style'; // keep other styles with suffix
      }

      final dartName = _toDartName(name) + suffix;

      final svgString = file.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      final rootAttrs = _extractRootAttrs(svgElement);
      final children = _extractChildren(svgElement);

      // Fluent icons use hardcoded fill colors on path elements (e.g. #212121)
      // instead of currentColor. Replace with currentColor for theming support.
      _replaceHardcodedFills(children);

      final content = <Map<String, dynamic>>[
        {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
        ...children,
      ];

      final preview = _makePreview(svgString, isStroke: false);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  print('  Found $totalFiles SVG files (24px only)');
  return icons;
}

// ---------------------------------------------------------------------------
// Font Awesome
// ---------------------------------------------------------------------------
List<IconEntry> _parseFontAwesome(IconFamily family) {
  final styleDirs = <String, String>{
    'solid': '',
    'regular': '_regular',
    'brands': '_brand',
  };

  final icons = <IconEntry>[];
  int totalFiles = 0;

  for (final entry in styleDirs.entries) {
    final dirPath = '${family.cloneDir}/svgs/${entry.key}';
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      print('  Warning: $dirPath not found, skipping');
      continue;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    totalFiles += files.length;

    for (final file in files) {
      final filename = _basename(file.path);
      final baseName = filename.replaceAll('.svg', '');
      String dartName = _toDartName(baseName);
      dartName = '$dartName${entry.value}';

      final svgString = file.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      final rootAttrs = _extractRootAttrs(svgElement);
      final children = _extractChildren(svgElement);

      final content = <Map<String, dynamic>>[
        {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
        ...children,
      ];

      final preview = _makePreview(svgString, isStroke: false);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  print('  Found $totalFiles SVG files');
  return icons;
}

// ---------------------------------------------------------------------------
// Remix Icon
// ---------------------------------------------------------------------------
List<IconEntry> _parseRemixIcon(IconFamily family) {
  final iconsDir = Directory('${family.cloneDir}/icons');
  if (!iconsDir.existsSync()) {
    print('  Error: icons/ directory not found in ${family.cloneDir}');
    return [];
  }

  final icons = <IconEntry>[];
  int totalFiles = 0;

  // Remix Icon has category subdirectories (Arrows, Buildings, Logos, etc.)
  // Both -line and -fill variants live in the same directory.
  final categoryDirs = iconsDir.listSync().whereType<Directory>().toList();

  for (final categoryDir in categoryDirs) {
    final files = categoryDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    totalFiles += files.length;

    for (final file in files) {
      final filename = _basename(file.path);
      String baseName = filename.replaceAll('.svg', '');

      // Determine style from filename suffix
      String suffix;
      if (baseName.endsWith('-fill')) {
        baseName = baseName.substring(0, baseName.length - '-fill'.length);
        suffix = '_fill';
      } else if (baseName.endsWith('-line')) {
        baseName = baseName.substring(0, baseName.length - '-line'.length);
        suffix = ''; // line is the base style
      } else {
        // Icons without style suffix — treat as base
        suffix = '';
      }

      final dartName = '${_toDartName(baseName)}$suffix';

      final svgString = file.readAsStringSync();
      final doc = XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      final rootAttrs = _extractRootAttrs(svgElement);
      final children = _extractChildren(svgElement);

      final content = <Map<String, dynamic>>[
        {'tag': 'root', 'family': family.familyTag, 'attrs': rootAttrs},
        ...children,
      ];

      final preview = _makePreview(svgString, isStroke: false);
      icons.add(
        IconEntry(name: dartName, content: content, previewSvg: preview),
      );
    }
  }
  print('  Found $totalFiles SVG files');
  return icons;
}

// ---------------------------------------------------------------------------
// SVG parsing helpers
// ---------------------------------------------------------------------------

/// Replace hardcoded fill colors (e.g. #212121) on child elements with
/// currentColor so icons respond to CSS color inheritance and theming.
void _replaceHardcodedFills(List<Map<String, dynamic>> children) {
  for (final child in children) {
    final attrs = child['attrs'] as Map<String, String>?;
    if (attrs != null && attrs.containsKey('fill')) {
      final fill = attrs['fill']!;
      // Replace any hardcoded hex color with currentColor
      if (fill.startsWith('#') || fill.startsWith('rgb')) {
        attrs['fill'] = 'currentColor';
      }
    }
    // Recurse into nested children (g, defs, etc.)
    if (child.containsKey('children')) {
      _replaceHardcodedFills(child['children'] as List<Map<String, dynamic>>);
    }
  }
}

/// Extract attributes from root `<svg>` that we care about.
Map<String, String> _extractRootAttrs(XmlElement svgElement) {
  final attrs = <String, String>{};
  for (final attr in svgElement.attributes) {
    if (_keepRootAttrs.contains(attr.localName)) {
      attrs[attr.localName] = attr.value;
    }
  }
  return attrs;
}

/// Recursively extract child elements from an SVG node.
List<Map<String, dynamic>> _extractChildren(XmlElement parent) {
  final result = <Map<String, dynamic>>[];
  for (final node in parent.children) {
    if (node is! XmlElement) continue;
    final tag = node.localName;

    final attrs = <String, String>{};
    for (final attr in node.attributes) {
      attrs[attr.localName] = attr.value;
    }

    // If it's a group element with children, extract recursively
    if (tag == 'g' || tag == 'defs' || tag == 'clipPath' || tag == 'mask') {
      final nestedChildren = _extractChildren(node);
      if (attrs.isNotEmpty || nestedChildren.isNotEmpty) {
        result.add({
          'tag': tag,
          'attrs': attrs,
          if (nestedChildren.isNotEmpty) 'children': nestedChildren,
        });
      }
    } else {
      result.add({'tag': tag, 'attrs': attrs});
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// Naming helpers
// ---------------------------------------------------------------------------

/// Convert a kebab-case basename to a valid Dart snake_case identifier.
String _toDartName(String baseName) {
  String name = baseName.replaceAll('-', '_').toLowerCase();

  // Prefix if starts with digit
  if (name.isNotEmpty && RegExp(r'^\d').hasMatch(name)) {
    name = 'icon_$name';
  }

  // Prefix if Dart keyword
  if (_dartKeywords.contains(name)) {
    name = 'icon_$name';
  }

  return name;
}

/// Get the filename from a path.
String _basename(String path) => path.split(Platform.pathSeparator).last;

// ---------------------------------------------------------------------------
// Preview SVG generation
// ---------------------------------------------------------------------------

/// Create a preview SVG string with currentColor replaced by #808080
/// and optional stroke attributes added for visibility.
String _makePreview(String svgString, {required bool isStroke}) {
  String preview = svgString;

  // Replace currentColor with gray for visibility
  preview = preview.replaceAll('currentColor', '#808080');

  // For stroke-based icons, add stroke="#808080" to child elements
  if (isStroke) {
    // Add stroke to path/circle/rect/line/polyline/polygon elements
    preview = preview.replaceAllMapped(
      RegExp(
        r'<(path|circle|rect|line|polyline|polygon|ellipse)\b([^>]*?)(/?)>',
      ),
      (match) {
        final tag = match.group(1)!;
        String attrs = match.group(2)!;
        final selfClose = match.group(3)!;
        if (!attrs.contains('stroke=')) {
          attrs = '$attrs stroke="#808080"';
        }
        return '<$tag$attrs$selfClose>';
      },
    );
  } else {
    // For fill-based icons, ensure path elements have fill="#808080" if they
    // don't already have a fill, or replace fill="currentColor"
    preview = preview.replaceAllMapped(
      RegExp(r'<(path|circle|rect|ellipse|polygon)\b([^>]*?)(/?)>'),
      (match) {
        final tag = match.group(1)!;
        String attrs = match.group(2)!;
        final selfClose = match.group(3)!;
        if (!attrs.contains('fill=')) {
          attrs = '$attrs fill="#808080"';
        }
        return '<$tag$attrs$selfClose>';
      },
    );
  }

  return preview;
}

// ---------------------------------------------------------------------------
// Dart file writer
// ---------------------------------------------------------------------------

void _writeDartFile(
  IconFamily family,
  List<IconEntry> icons,
  String outputDir,
) {
  final IconFamily(
    :licenseHeader,
    :key,
    :libraryName,
    :className,
    :outputFile,
  ) = family;
  final buffer = StringBuffer();

  // File header
  if (licenseHeader != null) {
    buffer.writeln(licenseHeader);
  } else {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  }
  buffer.writeln('// ignore_for_file: constant_identifier_names');
  buffer.writeln();
  buffer.writeln("import 'helpers.dart';");
  buffer.writeln();

  // Class doc comment
  if (key == 'fluent') {
    buffer.writeln('/// A collection of $libraryName icons (24px variants).');
  } else {
    buffer.writeln('/// A collection of $libraryName icons.');
  }
  buffer.writeln('abstract class $className {');
  buffer.writeln('  const $className._();');

  for (final icon in icons) {
    final IconEntry(:base64Preview, :altText, :name, :content) = icon;
    buffer.writeln();
    // Doc comment with base64 preview
    buffer.writeln(
      '  /// <img src="data:image/svg+xml;base64,$base64Preview" '
      'width="64" alt="$altText icon" '
      'style="background-color: #f0f0f0; border-radius: 4px; padding: 2px;">',
    );

    // Icon data constant
    buffer.writeln('  static const IconData $name = IconData([');
    for (final element in content) {
      _writeElement(buffer, element, indent: 4);
    }
    buffer.writeln('  ]);');
  }

  buffer.writeln('}');

  final outputPath = '$outputDir/$outputFile';
  File(outputPath).writeAsStringSync(buffer.toString());
  print('  Wrote $outputPath');
}

/// Write a single element map to the buffer with proper indentation.
void _writeElement(
  StringBuffer buffer,
  Map<String, dynamic> element, {
  required int indent,
}) {
  final pad = ' ' * indent;
  buffer.writeln('$pad{');

  final tag = element['tag'] as String;
  buffer.writeln("$pad  'tag': '$tag',");

  // Family field (only on root elements)
  if (element.containsKey('family')) {
    buffer.writeln("$pad  'family': '${element['family']}',");
  }

  // Attrs
  final attrs = element['attrs'];
  if (attrs != null) {
    final attrMap = attrs as Map<String, String>;
    if (attrMap.isEmpty) {
      buffer.writeln("$pad  'attrs': <String, String>{},");
    } else {
      buffer.writeln("$pad  'attrs': {");
      for (final attr in attrMap.entries) {
        final value = attr.value;
        // Use raw triple-quoted strings for all values
        if (value.length > 60) {
          // Long value → put on separate line with continuation indent
          buffer.writeln("$pad    '${attr.key}':");
          buffer.writeln("$pad        r'''$value''',");
        } else {
          buffer.writeln("$pad    '${attr.key}': r'''$value''',");
        }
      }
      buffer.writeln('$pad  },');
    }
  }

  // Nested children (for g, defs, clipPath, mask elements)
  if (element.containsKey('children')) {
    final children = element['children'] as List<Map<String, dynamic>>;
    buffer.writeln("$pad  'children': [");
    for (final child in children) {
      _writeElement(buffer, child, indent: indent + 4);
    }
    buffer.writeln('$pad  ],');
  }

  buffer.writeln('$pad},');
}
