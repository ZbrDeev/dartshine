import 'package:dartshine/src/templates/lexer/token.dart';

class Lexer {
  final List<Token> tokens = [];
  final List<String> sources;
  int position = 0;
  bool opentext = false;
  String guillemet = "";

  Lexer({required this.sources});

  void lexer() {
    String token = '';
    bool? isCommand;

    for (int i = 0; i < sources.length; i++) {
      String source = sources[i];

      if (opentext && !(source == '"' || source == '\'')) {
        token += source;
        continue;
      } else if (opentext && (source == '"' || source == '\'')) {
        tokens.add(Token(token: TokenEnum.stringValue, value: token));
        opentext = false;
        token = '';
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
                value: token.substring(0, token.length - 2)));
          }

          tokens.add(
              Token(token: TokenEnum.openCommandBalise, position: position));

          token = '';
          isCommand = true;
        } else if (sources[i + 1] == '>') {
          ++i;
          position = i;
          token = '';
          tokens.add(
              Token(token: TokenEnum.closeCommandBalise, position: position));
          isCommand = null;
        } else {
          token += source;
        }
      } else if (source == '\$') {
        if (sources[i - 1] == '<') {
          if (token.isNotEmpty) {
            tokens.add(Token(
                token: TokenEnum.content,
                value: token.substring(0, token.length - 2)));
          }

          token = '';
          tokens.add(
              Token(token: TokenEnum.openVariableBalise, position: position));
          isCommand = false;
        } else if (sources[i + 1] == '>') {
          ++i;
          position = i;
          token = '';
          tokens.add(
              Token(token: TokenEnum.closeVariableBalise, position: position));
          isCommand = null;
        } else {
          token += source;
        }
      } else if ((source == '"' || source == '\'') && isCommand != null) {
        guillemet = token;
        opentext = true;

        token = '';
      } else if (source == ' ') {
        if (token.trim().isNotEmpty) {
          if (isCommand == true) {
            lexeCommand(token);
            token = '';
            continue;
          } else if (isCommand == false) {
            tokens.add(Token(token: TokenEnum.variableName, value: token));
            token = '';
            continue;
          }

          token += source;
        }
      }
    }
  }

  void lexeCommand(String token) {
    if (token == 'for') {
      tokens.add(Token(token: TokenEnum.forCommand));
    } else if (token == 'if') {
      tokens.add(Token(token: TokenEnum.ifCommand));
    } else if (token == 'else') {
      tokens.add(Token(token: TokenEnum.elseCommand));
    } else if (token == 'in') {
      tokens.add(Token(token: TokenEnum.inCommand));
    } else if (token == 'endif') {
      tokens.add(Token(token: TokenEnum.endIfCommand));
    } else if (token == 'endfor') {
      tokens.add(Token(token: TokenEnum.endForCommand));
    } else if (token == '==') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '!=') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '&&') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '>') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '<') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '<=') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (token == '>=') {
      tokens.add(Token(token: TokenEnum.operator, value: token));
    } else if (int.tryParse(token) != null || double.tryParse(token) != null) {
      tokens.add(Token(token: TokenEnum.intValue, value: token));
    } else {
      tokens.add(Token(token: TokenEnum.variableName, value: token));
    }
  }
}
