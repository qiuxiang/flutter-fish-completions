import 'dart:io';
import 'types.dart';

Future<Command> parse([Command? command]) async {
  const OPTIONS = 1;
  const COMMANDS = 2;

  final arguments = ['help'];
  if (command != null) {
    if (command.parent?.parent != null) {
      arguments.add(command.parent!.name);
    }
    arguments.add(command.name);
  }
  final result = await Process.run('flutter', arguments);
  final lines = (result.stdout as String).split('\n');
  final optionsStarts = command == null ? 'Global options:' : 'Usage:';
  final optionRegExp = RegExp(r'(-[a-zA-Z],)?\s+(--.*?)?\s+(.*)');
  final commandRegExp = RegExp(r'\s+(.*?)\s+(.*)');
  final commands = <Future<Command>>[];

  var state;
  var short = '';
  var long = '';
  var description = '';

  if (command == null) {
    command = Command();
  }

  for (final line in lines) {
    if (line.startsWith(optionsStarts)) {
      state = OPTIONS;
      continue;
    }
    if (line.startsWith('Available commands:') ||
        line.startsWith('Available subcommands:')) {
      state = COMMANDS;
      continue;
    }
    if (state == OPTIONS) {
      if (line.endsWith(':')) continue;

      final match = optionRegExp.firstMatch(line);
      if (match != null) {
        final groups = match.groups([1, 2, 3]);
        if (groups[1] == null) {
          description += groups[2] ?? '';
        } else {
          if (long.isNotEmpty) {
            command.options.add(Option(
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
    } else if (state == COMMANDS) {
      if (line.isEmpty) break;
      final match = commandRegExp.firstMatch(line);
      if (match == null) break;
      commands.add(parse(Command(
        name: match.group(1) ?? '',
        description: match.group(2) ?? '',
        parent: command,
      )));
    }
  }

  if (long.isNotEmpty) {
    command.options.add(Option(
      short: short,
      long: long,
      description: description,
    ));
  }

  (await Future.wait(commands)).forEach(command.commands.add);

  return command;
}
