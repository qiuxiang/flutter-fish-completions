import 'dart:io';
import 'package:tuple/tuple.dart';

class Option {
  final String short;
  final String long;
  final String description;

  const Option({
    this.short = '',
    this.long = '',
    this.description = '',
  });

  @override
  String toString() {
    return [short, long, description].toString();
  }
}

class Command {
  final String name;
  final String description;
  final List<Option> options = const [];

  const Command(this.name, this.description);

  @override
  String toString() {
    return [name, description].toString();
  }
}

const STATE_OPTIONS = 1;
const STATE_COMMANDS = 2;

Future<Tuple2<List<Option>, List<Command>>> parse([String command = '']) async {
  final result = await Process.run(
      'flutter', command.isEmpty ? ['help', '-v'] : ['help', command, '-v']);
  final lines = (result.stdout as String).split('\n');
  final options = <Option>[];
  final commands = <Command>[];
  final optionsStartsWith = command.isEmpty ? 'Global options:' : 'Usage:';
  final optionRegExp = RegExp(r'(-[a-zA-Z],)?\s+(--.*?)?\s+(.*)');
  final commandRegExp = RegExp(r'\s+(.*?)\s+(.*)');

  var state;
  var short = '';
  var long = '';
  var description = '';

  for (final line in lines) {
    if (line.startsWith(optionsStartsWith)) {
      state = STATE_OPTIONS;
      continue;
    }
    if (line.startsWith('Available commands:')) {
      state = STATE_COMMANDS;
      continue;
    }
    if (state == STATE_OPTIONS) {
      if (line.endsWith(':')) continue;

      final match = optionRegExp.firstMatch(line);
      if (match != null) {
        final groups = match.groups([1, 2, 3]);
        if (groups[1] == null) {
          description += groups[2] ?? '';
        } else {
          if (long.isNotEmpty) {
            options.add(Option(
              short: short,
              long: long,
              description: description,
            ));
          }

          short = groups[0]?.substring(1, 2) ?? '';
          long = groups[1]?.substring(2) ?? '';
          description = groups[2] ?? '';
        }
      }
    } else if (state == STATE_COMMANDS) {
      if (line.isEmpty) break;
      final match = commandRegExp.firstMatch(line);
      commands.add(Command(match?.group(1) ?? '', match?.group(2) ?? ''));
    }
  }

  options.add(Option(
    short: short,
    long: long,
    description: description,
  ));

  return Tuple2(options, commands);
}

main() async {
  final result = await parse();
  final prefix = 'complete -c flutter';
  print('set -l commands ${result.item2.map((i) => i.name).join(' ')}');
  print('$prefix -f');
  for (final it in result.item1) {
    print('$prefix -s ${it.short} -l ${it.long} -d "${it.description}"');
  }
  for (final it in result.item2) {
    print(
        '$prefix -n "not __fish_seen_subcommand_from \$commands" -a ${it.name} -d "${it.description}"');
    final result = await parse(it.name);
    for (final i in result.item1) {
      final d = i.description.replaceAll('"', r'\"');
      print(
          '$prefix -n "__fish_seen_subcommand_from ${it.name}" -s ${i.short} -l "${i.long}" -d "$d"');
    }
  }
}
