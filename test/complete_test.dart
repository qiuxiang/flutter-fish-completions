import 'dart:io';

import 'package:test/test.dart';

void main() {
  Future<List<String>> getCompletions(String s) async {
    final result = await Process.run('fish', ['-c', 'complete -C"flutter $s"']);
    expect((result.stderr as String).isEmpty, true);
    final lines = (result.stdout as String).split('\n');
    lines.removeLast(); // remove the last empty line
    return lines.reversed.toList();
  }

  test('complete commands', () async {
    final lines = await getCompletions('');
    expect(lines.any((line) => line.contains('upgrade\tUpgrade your copy of Flutter.')), true);
    expect(lines.any((line) => line.contains('test\tRun Flutter unit tests for the current project.')), true);
  });

  test('complete global options', () async {
    final lines = await getCompletions('-');
    expect(lines.any((line) => line.startsWith('-d\tTarget device id or name (prefixes allowed).')), true);
    expect(lines.any((line) => line.startsWith('-h\tPrint this usage information.')), true);
  });

  test('complete flutter analyze options', () async {
    final lines = await getCompletions('analyze -');
    expect(lines.any((line) => line.startsWith('-d\tTarget device id or name (prefixes allowed).')), true);
    expect(lines.any((line) => line.startsWith('-h\tPrint this usage information.')), true);
  });
}
