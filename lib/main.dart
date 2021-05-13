import 'generate.dart' show generate;
import 'parse.dart';

void main() {
  parse().then(generate);
}
