import 'dart:convert';

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
    return JsonEncoder.withIndent('  ').convert(toJson());
  }

  toJson() => {'short': short, 'long': long, 'description': description};
}

class Command {
  final String name;
  final String description;
  final List<Option> options = [];
  final List<Command> commands = [];
  Command? parent;

  Command({this.name = '', this.description = '', this.parent});

  addCommand(Command command) {
    command.parent = this;
    commands.add(command);
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }

  toJson() => {
        'name': name,
        'description': description,
        'options': options.map((i) => i.toJson()).toList(),
        'commands': commands.map((i) => i.toJson()).toList(),
      };
}
