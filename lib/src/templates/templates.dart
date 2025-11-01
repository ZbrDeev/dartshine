import 'package:dartshine/src/templates/lexer/lexer.dart';
import 'package:dartshine/src/templates/parser/parser.dart';
import 'package:dartshine/src/templates/read_file.dart';
import 'package:dartshine/src/templates/render/render.dart';

/// **Template** is a class that uses the Dartshine template engine. You should provide an HTML file path.
///
/// ## Example
/// ```dart
/// Template(path: 'assets/index.html').render(variableList: {
///   'name': 'John Doe',
///   'age': 24,
///   'hobbies': ['programming', 'cooking']
/// });
/// ```
class Template {
  List<String> sources = [];
  final String path;

  Template({required this.path}) {
    sources = readFile(path);
  }

  /// Used to render with variable lists
  String render({Map<String, dynamic> variableList = const {}}) {
    final Lexer lexer = Lexer(sources: sources);
    lexer.lexer();

    final Parser parser = Parser(tokens: lexer.tokens, filename: path);
    parser.parser();

    final Render render = Render(
        root: parser.root,
        variableList: variableList,
        sources: sources,
        filename: path);
    render.render();

    return render.sources.join();
  }
}
