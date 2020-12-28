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
    return;
  }
  var s = buildOption(option, command);
  if (option.short == 'd') {
    s += ' -xa "(__fish_flutter_devices)"';
  }
  print(s);
}

void genSubcommand(Command command, String commands) {
  var n = 'not __fish_seen_subcommand_from $commands';
  var parent = command.parent;
  if (parent?.parent != null) {
    n = '__fish_seen_subcommand_from ${parent?.name}; and ' + n;
  }
  print('$c -f -n "$n" -a ${command.name} -d "${command.description}"');
}

void generate(Command command) {
  print(r'''
complete -c flutter -f -n "__fish_seen_subcommand_from channel" -a "(flutter channel | tail -n +2 | sed 's/\s//g' | sed 's/*\(\w\+\)/\1\tcurrent/')"
function __fish_flutter_devices -d 'Run flutter devices and parse output'
  flutter devices | tail -n +3 | sed -r 's/ \(\w+\)\s+• /\t/g'
end''');
  command.options.forEach(genOption);
  final commands = command.commands.map((i) => i.name).join(' ');
  print('set -l commands $commands');
  command.commands.add(Command(name: 'help'));
  command.commands.forEach((it) {
    genSubcommand(it, '\$commands');
    it.options.forEach((option) => genOption(option, it));
    where(Command i) => i.name != it.name;
    final subcommands = it.commands.where(where).map((i) => i.name).join(' ');
    final name = '${it.name}_commands';
    if (it.commands.isNotEmpty) {
      print('set -l $name $subcommands');
    }
    it.commands.forEach((it) {
      genSubcommand(it, '\$$name');
      it.options.forEach((option) => genOption(option, it));
    });
  });
}
