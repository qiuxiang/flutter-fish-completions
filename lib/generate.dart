import 'types.dart';

const c = 'complete -c flutter';

String escape(String s) {
  return s.trim().replaceAll('"', r'\"');
}

String buildOption(Option option, [Command? command]) {
  var completion = '$c -l "${option.long}" -d "${escape(option.description)}"';
  if (option.short.isNotEmpty) {
    completion += ' -s ${option.short}';
  }
  if (command != null) {
    var n = '__fish_seen_subcommand_from ${command.name}';
    if (command.parent?.parent != null) {
      n = '__fish_seen_subcommand_from ${command.parent?.name};' + n;
    }
    completion += ' -n "$n"';
  }
  return completion;
}

void genOption(Option option, [Command? command]) {
  if (option.long.startsWith('[no-]')) {
    gen(String long) => print(buildOption(
        Option(long: long, description: option.description), command));
    gen(option.long.replaceAll('[no-]', ''));
    gen(option.long.replaceAll('[no-]', 'no-'));
  } else {
    print(buildOption(option, command));
  }
}

void genSubcommand(Command command, String commands) {
  var n = 'not __fish_seen_subcommand_from $commands';
  var parent = command.parent;
  if (parent?.parent != null) {
    n = '__fish_seen_subcommand_from ${parent?.name}; and ' + n;
  }
  print('$c -n "$n" -a ${command.name} -d "${command.description}"');
}

void generate(Command command) {
  print('$c -f');
  command.options.forEach(genOption);
  final commands = command.commands.map((i) => i.name).join(' ');
  command.commands.add(Command(name: 'help'));
  command.commands.forEach((it) {
    genSubcommand(it, commands);
    it.options.forEach((option) => genOption(option, it));
    where(Command i) => i.name != it.name;
    final subcommands = it.commands.where(where).map((i) => i.name).join(' ');
    it.commands.forEach((it) {
      genSubcommand(it, subcommands);
      it.options.forEach((option) => genOption(option, it));
    });
  });
}
