import 'package:test/test.dart';
import 'dart:io';

main() {
  Future<List<String>> getCompletions(String s) async {
    final result = await Process.run('fish', ['-c', 'complete -C"flutter $s"']);
    expect((result.stderr as String).isEmpty, true);
    final lines = (result.stdout as String).split('\n');
    lines.removeLast(); // remove the last empty line
    return lines;
  }

  test('complete commands', () async {
    final lines = await getCompletions('');
    expect(lines.first, 'upgrade	Upgrade your copy of Flutter.');
    expect(lines.last, 'analyze	Analyze the project\'s Dart code.');
  });

  test('complete global options', () async {
    final lines = await getCompletions('-');
    expect(lines[2],
        '--show-web-server-device	List the special \'web-server\' device in device listings.');
    expect(lines.last, '-h	Print this usage information.');
  });

  test('complete flutter analyze options', () async {
    final lines = await getCompletions('analyze -');
    expect(lines.first,
        '--[no-]fatal-warnings	Treat warning level issues as fatal.(defaults to on)');
  });
}
