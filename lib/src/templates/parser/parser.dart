import 'package:dartshine/src/error/template_error.dart';
import 'package:dartshine/src/templates/lexer/token.dart';

class Parser {
  final List<Map<String, dynamic>> results = [];
  int index = 0;
  final List<Token> tokens;

  Parser({required this.tokens});

  void parser() {
    while (index < tokens.length) {
      Token token = tokens[index];

      if (token.token == TokenEnum.openCommandBalise) {
        parseCommand(node: results, position: token.position!);
      } else if (token.token == TokenEnum.openVariableBalise) {
        parseVariable(node: results, position: token.position!);
      }

      index++;
    }
  }

  void parseCommand(
      {required List<Map<String, dynamic>> node, required int position}) {
    index++;
    Token token = tokens[index];

    if (token.token == TokenEnum.ifCommand) {
      parseCondition(node: node, condition: true, position: position);
    } else if (token.token == TokenEnum.forCommand) {
      parseFor(node: node, position: position);
    } else {
      throw InvalidCommandToken(tokenEnum: token.token);
    }
  }

  void parseVariable(
      {required List<Map<String, dynamic>> node, required int position}) {
    index++;
    Token token = tokens[index];
    Map<String, dynamic> result = {};

    if (token.token == TokenEnum.variableName) {
      result['type'] = 'variable';
      result['name'] = token.value!;
    } else {
      throw InvalidVariableName(tokenEnum: token.token);
    }

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.closeVariableBalise) {
      throw InvalidCloseBalise(isCommand: false);
    }

    result['startPosition'] = position;
    result['endPosition'] = token.position!;

    node.add(result);
  }

  void parseIfCondition({required Map<String, dynamic> node}) {
    List<Token> tokenList = [];

    while (true) {
      index++;
      Token token = tokens[index];

      if (token.token == TokenEnum.closeCommandBalise) {
        node['condition'] = tokenList;
        break;
      } else if (token.token == TokenEnum.variableName ||
          token.token == TokenEnum.operator ||
          token.token == TokenEnum.intValue ||
          token.token == TokenEnum.stringValue) {
        tokenList.add(token);
      } else {
        throw InvalidIfCondition(tokenEnum: token.token);
      }
    }
  }

  void parseCondition(
      {required List<Map<String, dynamic>> node,
      required bool condition,
      Map<String, dynamic>? elseNode,
      required int position}) {
    Token token = tokens[index];
    Map<String, dynamic> result = {'type': 'condition'};

    if (condition) {
      parseIfCondition(node: result);
    } else {
      index++;
      token = tokens[index];

      if (token.token != TokenEnum.closeCommandBalise) {
        throw InvalidCloseBalise(isCommand: true);
      }
    }

    List<Map<String, dynamic>> children = [];

    while (true) {
      token = tokens[index];

      if (token.token == TokenEnum.openCommandBalise &&
          tokens[index + 1].token == TokenEnum.endIfCommand &&
          tokens[index + 2].token == TokenEnum.closeCommandBalise) {
        index += 2;
        break;
      } else if (token.token == TokenEnum.openCommandBalise &&
          tokens[index + 1].token == TokenEnum.elseCommand &&
          tokens[index + 2].token == TokenEnum.closeCommandBalise) {
        index++;
        parseCondition(
            node: node,
            condition: false,
            elseNode: result,
            position: token.position!);
        break;
      } else if (token.token == TokenEnum.openVariableBalise) {
        parseVariable(node: children, position: token.position!);
      } else if (token.token == TokenEnum.openCommandBalise) {
        parseCommand(node: children, position: token.position!);
      } else if (token.token == TokenEnum.content) {
        children.add({'type': 'text', 'value': token.value});
      }

      index++;
    }

    token = tokens[index];

    result['startPosition'] = position;
    result['endPosition'] = token.position;

    if (condition) {
      result['trueCondition'] = children;
      node.add(result);
    } else {
      elseNode!['falseCondition'] = children;
    }
  }

  void parseFor(
      {required List<Map<String, dynamic>> node, required int position}) {
    index++;
    Token token = tokens[index];
    Map<String, dynamic> forCondition = {'type': 'for'};

    if (token.token != TokenEnum.variableName) {
      throw InvalidVariableName(tokenEnum: token.token);
    }

    forCondition['variable'] = token.value!;

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.inCommand) {
      throw InvalidForInCondition(tokenEnum: token.token);
    }

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.variableName) {
      throw InvalidVariableName(tokenEnum: token.token);
    }

    if (tokens[index + 1].token != TokenEnum.closeCommandBalise) {
      throw InvalidCloseBalise(isCommand: true);
    }

    index++;

    forCondition['collection'] = token.value!;

    List<Map<String, dynamic>> children = [];

    while (true) {
      index++;
      token = tokens[index];

      if (token.token == TokenEnum.openCommandBalise &&
          tokens[index + 1].token == TokenEnum.endForCommand &&
          tokens[index + 2].token == TokenEnum.closeCommandBalise) {
        index += 2;
        break;
      } else if (token.token == TokenEnum.openVariableBalise) {
        parseVariable(node: children, position: token.position!);
      } else if (token.token == TokenEnum.content) {
        children.add({'type': 'text', 'value': token.value});
      } else if (token.token == TokenEnum.openCommandBalise) {
        parseCommand(node: children, position: token.position!);
      } else {
        throw InvalidBaliseToken();
      }
    }

    token = tokens[index];

    forCondition['startPosition'] = position;
    forCondition['endPosition'] = token.position;

    forCondition['children'] = children;

    node.add(forCondition);
  }
}
