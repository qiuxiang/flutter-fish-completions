import 'package:flutter_fish_completions/main.dart';
import 'package:test/test.dart';

main() {
  test('flutter parse', () async {
    final command = await parse();
    expect(command.options[1].short, 'v');
    expect(command.options[1].long, 'verbose');
    expect(command.options[1].description,
        'Noisy logging, including all shell commands executed.If used with --help, shows hidden options.');
    expect(command.commands[1].name, 'assemble');
    expect(command.commands[1].description,
        'Assemble and build Flutter resources.');
    expect(command.commands[1].options.last.short, '');
    expect(command.commands[1].options.last.long, 'resource-pool-size');
    expect(command.commands[1].options.last.description,
        'The maximum number of concurrent tasks the build system will run.');
  });

  test('flutter analyze parse', () async {
    final command = await parse(Command(name: 'analyze'));
    expect(command.options.first.short, 'h');
    expect(command.options.first.long, 'help');
    expect(command.options.first.description, 'Print this usage information.');
    expect(command.options.last.short, '');
    expect(command.options.last.long, '[no-]fatal-warnings');
    expect(command.options.last.description,
        'Treat warning level issues as fatal.(defaults to on)');
  });

  test('flutter build parse', () async {
    final command = await parse(Command(name: 'build', parent: Command()));
    expect(command.commands.first.name, 'aar');
    expect(command.commands.first.description,
        'Build a repository containing an AAR and a POM file.');
    expect(command.commands.first.options.last.short, '');
    expect(command.commands.first.options.last.long, 'output-dir');
    expect(command.commands.first.options.last.description,
        'The absolute path to the directory where the repository is generated. By default, this is \'<current-directory>android/build\'. ');
  });
}
