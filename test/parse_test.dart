import 'package:flutter_fish_completions/parse.dart';
import 'package:flutter_fish_completions/types.dart';
import 'package:test/test.dart';

void main() {
  test('parse command `flutter help`', () async {
    final command = Command();
    await parseCommand(command);
    expect(command.options.length, greaterThan(0));
    expect(command.commands.length, greaterThan(0));
    
    // Check that we have basic global options
    expect(command.options.any((option) => option.long == 'help'), true);
    expect(command.options.any((option) => option.long == 'verbose'), true);
    
    // Check that we have some common commands
    expect(command.commands.any((cmd) => cmd.name == 'upgrade'), true);
    expect(command.commands.any((cmd) => cmd.name == 'config'), true);
  });

  test('parse command `flutter help build`', () async {
    final command = Command(name: 'build');
    await parseCommand(command);
    expect(command.commands.length, greaterThan(0));
    
    // Check that we have some build subcommands
    expect(command.commands.any((cmd) => cmd.name == 'apk'), true);
  });

  test('parse command `flutter help config`', () async {
    final command = Command(name: 'config');
    await parseCommand(command);
    expect(command.commands.length, 0);
    expect(command.options.length, greaterThan(0));
    
    // Check that we have some config options
    expect(command.options.any((option) => option.long == 'list'), true);
  });
}
