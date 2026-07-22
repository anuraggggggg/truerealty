import 'dart:io';

void main() {
  final file = File('lib/screen/follow_up_test_screen.dart');
  if (!file.existsSync()) {
    print('Error: lib/screen/follow_up_test_screen.dart not found.');
    exit(1);
  }

  String content = file.readAsStringSync();

  final Map<String, String> mapping = {
    'fontSize: 32.sp': 'fontSize: 34.sp',
    'fontSize: 14': 'fontSize: 16',
    'fontSize: 17.sp': 'fontSize: 19.sp',
    'fontSize: 16.sp': 'fontSize: 18.sp',
    'fontSize: 15.sp': 'fontSize: 17.sp',
    'fontSize: 18': 'fontSize: 20',
    'fontSize: 12': 'fontSize: 14',
    'fontSize: 8': 'fontSize: 10',
    'fontSize: 24': 'fontSize: 26',
    'fontSize: 28.sp': 'fontSize: 30.sp',
    'fontSize: 20.sp': 'fontSize: 22.sp',
    'fontSize: 10': 'fontSize: 12',
  };

  final regex = RegExp(r'fontSize:\s*(\d+(?:\.sp)?)');
  int totalReplaced = 0;

  final newContent = content.replaceAllMapped(regex, (match) {
    final matchedText = match.group(0)!;
    // Normalize spaces for map lookup, e.g. "fontSize:   14" -> "fontSize: 14"
    final normalized = matchedText.replaceAll(RegExp(r'\s+'), ' ');
    if (mapping.containsKey(normalized)) {
      totalReplaced++;
      final replacement = mapping[normalized]!;
      print('Replacing "$matchedText" with "$replacement"');
      return replacement;
    } else {
      print('Warning: Matched "$matchedText" but no mapping was found.');
      return matchedText;
    }
  });

  if (totalReplaced == 53) {
    file.writeAsStringSync(newContent);
    print('SUCCESS: Replaced all 53 occurrences of fontSize.');
  } else {
    print('ERROR: Expected 53 replacements, but only found $totalReplaced. File NOT modified.');
    exit(1);
  }
}
