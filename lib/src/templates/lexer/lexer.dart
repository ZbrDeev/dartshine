import 'package:dartshine/src/templates/lexer/token.dart';

class Lexer {
  final List<Token> tokens = [];
  final List<String> sources;
  int position = 0;
  bool opentext = false;
  String guillemet = "";

  int line = 1;
  int column = 1;

  Lexer({required this.sources});

  void lexer() {
    String token = '';
    bool? isCommand;

    for (int i = 0; i < sources.length; i++) {
      String source = sources[i];
      ++column;

      if (opentext && !(source == '"' || source == '\'')) {
        token += source;
        continue;
      } else if (opentext && (source == '"' || source == '\'')) {
        tokens.add(Token(
            token: TokenEnum.stringValue,
            column: column,
            line: line,
            value: token));
        opentext = false;
        token = '';
        continue;
      }

      if (source == '\n') {
        ++line;
        column = 1;
        continue;
      }

      if (source != ' ') {
        token += source;
      }

      if (source == '<') {
        position = i;
      } else if (source == '#') {
        if (sources[i - 1] == '<') {
          if (token.isNotEmpty) {
            tokens.add(Token(
                token: TokenEnum.content,
                column: column,
                line: line,
                value: token.substring(0, token.length - 2)));
          }

          tokens.add(Token(
              token: TokenEnum.openCommandBalise,
              column: column,
              line: line,
              position: position));

          token = '';
          isCommand = true;
        } else if (sources[i + 1] == '>') {
          ++i;
          position = i;
          token = '';
          tokens.add(Token(
              token: TokenEnum.closeCommandBalise,
              column: column,
              line: line,
              position: position));
          isCommand = null;
        } else {
          token += source;
        }
      } else if (source == '\$') {
        if (sources[i - 1] == '<') {
          if (token.isNotEmpty) {
            tokens.add(Token(
                token: TokenEnum.content,
                column: column,
                line: line,
                value: token.substring(0, token.length - 2)));
          }

          token = '';
          tokens.add(Token(
              token: TokenEnum.openVariableBalise,
              column: column,
              line: line,
              position: position));
          isCommand = false;
        } else if (sources[i + 1] == '>') {
          ++i;
          position = i;
          token = '';
          tokens.add(Token(
              token: TokenEnum.closeVariableBalise,
              column: column,
              line: line,
              position: position));
          isCommand = null;
        } else {
          token += source;
        }
      } else if ((source == '"' || source == '\'') && isCommand != null) {
        guillemet = token;
        opentext = true;

        token = '';
      } else if (source == ' ' || source == '.' || source == '[') {
        if (token.trim().isNotEmpty) {
          if (source == '.' || source == '[') {
            token = token.substring(0, token.length - 1);
          }

          if (isCommand == true && token.isNotEmpty) {
            lexeCommand(token);
            token = '';
          } else if (isCommand == false && token.isNotEmpty) {
            tokens.add(Token(
                token: TokenEnum.variableName,
                column: column,
                line: line,
                value: token));
            token = '';
          }

          token += source;
        }

        if (source == '.' &&
            tokens.isNotEmpty &&
            (tokens.last.token == TokenEnum.variableName ||
                tokens.last.token == TokenEnum.closeBracket)) {
          token = '';
          tokens.add(Token(
            token: TokenEnum.dot,
            column: column,
            line: line,
          ));
        } else if (source == '[' &&
            tokens.isNotEmpty &&
            (tokens.last.token == TokenEnum.variableName ||
                tokens.last.token == TokenEnum.closeBracket)) {
          token = '';
          tokens.add(Token(
            token: TokenEnum.openBracket,
            column: column,
            line: line,
          ));
        }
      } else if (source == ']') {
        token = token.substring(0, token.length - 1);

        if (int.tryParse(token) != null || double.tryParse(token) != null) {
          tokens.add(Token(
              token: TokenEnum.intValue,
              column: column,
              line: line,
              value: token));
        }

        token = '';
        tokens.add(Token(
          token: TokenEnum.closeBracket,
          column: column,
          line: line,
        ));
      }
    }
  }

  void lexeCommand(String token) {
    token = token.trim();

    if (token.isEmpty) {
      return;
    }

    if (token == 'for') {
      tokens.add(Token(
        token: TokenEnum.forCommand,
        column: column,
        line: line,
      ));
    } else if (token == 'if') {
      tokens.add(Token(
        token: TokenEnum.ifCommand,
        column: column,
        line: line,
      ));
    } else if (token == 'else') {
      tokens.add(Token(
        token: TokenEnum.elseCommand,
        column: column,
        line: line,
      ));
    } else if (token == 'in') {
      tokens.add(Token(
        token: TokenEnum.inCommand,
        column: column,
        line: line,
      ));
    } else if (token == 'endif') {
      tokens.add(Token(
        token: TokenEnum.endIfCommand,
        column: column,
        line: line,
      ));
    } else if (token == 'endfor') {
      tokens.add(Token(
        token: TokenEnum.endForCommand,
        column: column,
        line: line,
      ));
    } else if (token == '==') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '!=') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '&&') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '>') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '<') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '<=') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (token == '>=') {
      tokens.add(Token(
          token: TokenEnum.operator, column: column, line: line, value: token));
    } else if (int.tryParse(token) != null || double.tryParse(token) != null) {
      tokens.add(Token(
          token: TokenEnum.intValue, column: column, line: line, value: token));
    } else {
      tokens.add(Token(
          token: TokenEnum.variableName,
          column: column,
          line: line,
          value: token));
    }
  }
}
