import 'package:flutter_fish_completions/parse2.dart';
import 'package:flutter_fish_completions/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse command `flutter help`', () async {
    final command = Command();
    await parseCommand(command);
    expect(command.options[0].short, 'h');
    expect(command.options[0].long, 'help');
    expect(command.options[0].description, 'Print this usage information.');
    expect(command.commands[0].name, 'bash-completion');
    expect(command.commands[1].name, 'channel');
  });

  test('parse command `flutter help build`', () async {
    final command = Command(name: 'build');
    await parseCommand(command);
    expect(command.options, []);
    expect(command.commands[0].name, 'aar');
  });

  test('parse', () async {
    await parse();
  });
}
