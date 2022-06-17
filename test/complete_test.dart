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
    expect(lines[0], 'bash-completion\tOutput command line shell completion setup scripts.');
    expect(lines[1], 'channel\tList or switch Flutter channels.');
  });

  test('complete global options', () async {
    final lines = await getCompletions('-');
    expect(lines.first, '-h	Print this usage information.');
    expect(lines[2].startsWith('-v\tNoisy logging'), true);
  });

  test('complete flutter analyze options', () async {
    final lines = await getCompletions('analyze -');
    expect(lines.last,
        '--no-fatal-warnings\tTreat warning level issues as fatal. (defaults to on)');
  });
}
