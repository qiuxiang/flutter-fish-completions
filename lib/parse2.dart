import 'dart:io';

import 'types.dart';

enum State {
  options,
  commands,
}

final optionExp = RegExp(r'(-[a-zA-Z],)?\s+(--.*?)?\s+(.*)');
final commandExp = RegExp(r'  (.*?)\s+(.*)');
final commandsHeaderExp = RegExp(r'Available (sub)?commands:');

Future<void> parseCommand(Command command) async {
  final arguments = <String>[];
  final parent = command.parent;
  if (parent != null) {
    arguments.add(parent.name);
  }
  if (command.name.isNotEmpty) {
    arguments.add(command.name);
  }
  arguments.add('-h');
  arguments.add('-v');

  final lines = (await Process.run('flutter', arguments)).stdout.split('\n');
  final optionsStart = command.name.isEmpty ? 'Global options:' : 'Usage:';
  var short = '';
  var long = '';
  var description = '';
  State? state;
  for (final line in lines) {
    if (line.startsWith(optionsStart)) {
      state = State.options;
      continue;
    }

    if (commandsHeaderExp.hasMatch(line)) {
      state = State.commands;
      continue;
    }

    if (state == State.options) {
      if (line.isEmpty || line.endsWith(':')) {
        continue;
      }

      final match = optionExp.firstMatch(line);
      if (match != null) {
        final groups = match.groups([1, 2, 3]);
        if (groups[1] == null) {
          description += ' ' + groups[2]!;
        } else {
          if (long.isNotEmpty && (command.name.isEmpty || short != 'h')) {
            command.options.add(Option(
              short: short,
              long: long,
              description: description,
            ));
          }

          short = groups[0]?.substring(1, 2) ?? '';
          long = groups[1]?.substring(2).replaceAll(RegExp(r'=<.*'), '') ?? '';
          description = groups[2] ?? '';
        }
      }
    } else if (state == State.commands) {
      final match = commandExp.firstMatch(line);
      if (match == null) {
        continue;
      }

      command.addCommand(Command(
        name: match.group(1)!,
        description: match.group(2)!,
        parent: command,
      ));
    }
  }

  if (long.isNotEmpty && (command.name.isEmpty || short != 'h')) {
    command.options.add(Option(
      short: short,
      long: long,
      description: description,
    ));
  }
}

parse() async {
  final command = Command();
  await parseCommand(command);
  for (final subcommand in command.commands) {
    print(subcommand.name);
    await parseCommand(subcommand);
    print(subcommand.commands);
    // for (final subcommand in subcommand.commands) {
    //   print('  ' + subcommand.name);
    //   await parseCommand(subcommand);
    // }
  }
}
