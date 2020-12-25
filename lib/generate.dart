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

generate(Command command) {
  print('$c -f');
  command.options.forEach((it) => print(buildOption(it)));
  command.commands.forEach((it) {
    print('$c -n "__fish_use_subcommand" -a ${it.name} -d "${it.description}"');
    it.options.forEach((option) => print(buildOption(option, it)));
    final commands = it.commands
        .where((i) => i.name != it.name)
        .map((i) => i.name)
        .join(' ');
    it.commands.forEach((it) {
      final n = '__fish_seen_subcommand_from ${it.parent?.name};' +
          'and not __fish_seen_subcommand_from $commands';
      print('$c -n "$n" -a ${it.name} -d "${it.description}"');
      it.options.forEach((option) => print(buildOption(option, it)));
    });
  });
}
