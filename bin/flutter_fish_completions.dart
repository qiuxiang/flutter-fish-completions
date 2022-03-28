import 'package:flutter_fish_completions/generate.dart';
import 'package:flutter_fish_completions/parse.dart';

void main() async {
  parse().then(generate);
}
