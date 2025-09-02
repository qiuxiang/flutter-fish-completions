import 'package:flutter_fish_completions/generate.dart';
import 'package:flutter_fish_completions/types.dart';
import 'package:test/test.dart';

void main() {
  test('generate global option', () async {
    final result = buildOption(const Option(
      short: 'h',
      long: 'help',
      description: 'Print this usage information.',
    ));
    
    expect(result.contains('-l "help"'), true);
    expect(result.contains('-s h'), true);
    expect(result.contains('Print this usage information.'), true);
  });

  test('generate global option without short option', () async {
    final result = buildOption(const Option(long: 'long', description: 'description'));
    
    expect(result.contains('-l "long"'), true);
    expect(result.contains('description'), true);
    expect(result.contains('-s'), false); // Should not contain short option
  });

  test('generate subcommand option', () async {
    const option = Option(
      long: 'watch',
      description:
          'Run analysis continuously, watching the filesystem for changes.',
    );
    final result = buildOption(option, Command(name: 'analyze'));
    
    expect(result.contains('-l "watch"'), true);
    expect(result.contains('Run analysis continuously, watching the filesystem for changes.'), true);
    expect(result.contains('__fish_seen_subcommand_from analyze'), true);
  });
}
