import 'package:flutter_fish_completions/generate.dart';
import 'package:flutter_fish_completions/types.dart';
import 'package:test/test.dart';

void main() {
  test('generate global option', () async {
    expect(
      buildOption(const Option(
        short: 'h',
        long: 'help',
        description: 'Print this usage information.',
      )),
      'complete -c flutter -l "help" -d "Print this usage information." -s h',
    );
  });

  test('generate global option without short option', () async {
    expect(
      buildOption(const Option(long: 'long', description: 'description')),
      'complete -c flutter -l "long" -d "description"',
    );
  });

  test('generate subcommand option', () async {
    const option = Option(
      long: 'watch',
      description:
          'Run analysis continuously, watching the filesystem for changes.',
    );
    expect(
      buildOption(option, Command(name: 'analyze')),
      'complete -c flutter -l "watch" -d "Run analysis continuously, watching the filesystem for changes." -n "__fish_seen_subcommand_from analyze"',
    );
  });
}
