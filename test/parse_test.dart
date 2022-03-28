import 'package:flutter_fish_completions/parse.dart';
import 'package:flutter_fish_completions/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter parse', () async {
    final command = await parse();
    expect(command.options[1].short, 'v');
    expect(command.options[1].long, 'verbose');
    expect(command.options[1].description.startsWith('Noisy logging'), true);
    expect(command.commands[1].name, 'assemble');
    expect(command.commands[1].description,
        'Assemble and build Flutter resources.');
    expect(command.commands[1].options.last.short, '');
    expect(command.commands[1].options.last.long, 'resource-pool-size');
    expect(command.commands[1].options.last.description,
        'The maximum number of concurrent tasks the build system will run.');
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('flutter analyze parse', () async {
    final options = (await parse(Command(name: 'analyze'))).options;
    expect(options.first.short, 'h');
    expect(options.first.long, 'help');
    expect(options.first.description, 'Print this usage information.');
    expect(options.last.short, '');
    expect(options.last.long, '[no-]fatal-warnings');
    expect(options.last.description,
        'Treat warning level issues as fatal.(defaults to on)');
  });

  test('flutter build parse', () async {
    final result = await parse(Command(name: 'build', parent: Command()));
    final command = result.commands.first;
    expect(command.name, 'aar');
    expect(command.description,
        'Build a repository containing an AAR and a POM file.');
    final option = command.options.last;
    expect(option.short, '');
    expect(option.long, 'output-dir');
    expect(option.description.startsWith('The absolute path'), true);
  });
}
