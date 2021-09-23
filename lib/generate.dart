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
      n = '${'__fish_seen_subcommand_from ${command.parent?.name};'}$n';
    }
    completion += ' -n "$n"';
  }
  return completion;
}

void genOption(Option option, [Command? command]) {
  if (option.long.startsWith('[no-]')) {
    void gen(String long) => print(buildOption(
        Option(long: long, description: option.description), command));
    gen(option.long.replaceAll('[no-]', ''));
    gen(option.long.replaceAll('[no-]', 'no-'));
    return;
  }
  var s = buildOption(option, command);
  switch (option.long) {
    case 'device-id':
      s += ' -xa "(__fish_flutter_devices)"';
      break;
    case 'launch':
      s += ' -xa "(__fish_flutter_emulators)"';
      break;
    case 'target-platform':
      s += ' -xa "(__fish_flutter_target_platforms)"';
      break;
  }
  print(s);
}

void genSubcommand(Command command, String commands) {
  var n = 'not __fish_seen_subcommand_from $commands';
  var parent = command.parent;
  if (parent?.parent != null) {
    n = '${'__fish_seen_subcommand_from ${parent?.name}; and '}$n';
  }
  print('$c -f -n "$n" -a ${command.name} -d "${command.description}"');
}

void generate(Command command) {
  print(r'''
complete -c flutter -f -n "__fish_seen_subcommand_from channel" -a "(flutter channel | tail -n +2 | sed 's/\s//g' | sed 's/*\(\w\+\)/\1\tcurrent/')"
function __fish_flutter_devices
  flutter devices | tail -n +3 | sed -r 's/ \(\w+\)\s+• /\t/g'
end
function __fish_flutter_emulators
  flutter emulators | head -n -7 | tail -n +3 | sed -r 's/(\w+)(\s+)• /\1\t/'
end
function __fish_flutter_target_platforms
  flutter build apk -h | grep android-arm | sed -r 's/\s+\[|\]|\)//g' | sed -r 's/, /\n/g' | sed -r 's/ \(/\t/g' | sed -r 's/x86/x86\t /'
end''');
  command.options.forEach(genOption);
  final commands = command.commands.map((i) => i.name).join(' ');
  print('set -l commands $commands');
  command.commands.add(Command(name: 'help'));
  for (final it in command.commands) {
    genSubcommand(it, '\$commands');
    it.options.forEach((option) => genOption(option, it));
    bool where(Command i) => i.name != it.name;
    final subcommands = it.commands.where(where).map((i) => i.name).join(' ');
    final name = '${it.name}_commands'.replaceAll('-', '_');
    if (it.commands.isNotEmpty) {
      print('set -l $name $subcommands');
    }
    for (final it in it.commands) {
      genSubcommand(it, '\$$name');
      it.options.forEach((option) => genOption(option, it));
    }
  }
}
