import 'package:dartshine/src/templates/lexer/token.dart';

class Parser {
  bool error = false;
  final List<Map<String, dynamic>> results = [];
  int index = 0;
  final List<Token> tokens;

  Parser({required this.tokens});

  void parser() {
    while (index < tokens.length) {
      Token token = tokens[index];

      if (token.token == TokenEnum.openCommandBalise) {
        // TODO: ADD COMMAND PARSER FUNCTIONNALITY
        // TODO: FOR NOW ADD AN ERROR TO SAY ITS NOT IMPLEMENTED YET
      } else if (token.token == TokenEnum.openVariableBalise) {
        parseVariable(node: results, position: token.position!);
      } else {
        error = true;
      }

      if (error) {
        return;
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
      error = true;
      return;
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
      error = true;
      return;
    }

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.closeVariableBalise) {
      error = true;
      return;
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
        error = true;
        return;
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

      if (error) {
        return;
      }
    } else {
      index++;
      token = tokens[index];

      if (token.token != TokenEnum.closeCommandBalise) {
        error = true;
        return;
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
      } else if (token.token == TokenEnum.openBrace) {
        index++;
        token = tokens[index];

        if (token.token == TokenEnum.content &&
            tokens[index + 1].token == TokenEnum.closeBrace) {
          children.add({'type': 'text', 'value': token.value});
          index++;
        } else {
          error = true;
          return;
        }
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
      error = true;
      return;
    }

    forCondition['variable'] = token.value!;

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.inCommand) {
      error = true;
      return;
    }

    index++;
    token = tokens[index];

    if (token.token != TokenEnum.variableName ||
        tokens[index + 1].token != TokenEnum.closeCommandBalise) {
      error = true;
      return;
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
      } else if (token.token == TokenEnum.openBrace) {
        index++;
        token = tokens[index];

        if (token.token == TokenEnum.content &&
            tokens[index + 1].token == TokenEnum.closeBrace) {
          children.add({'type': 'text', 'value': token.value});
          index++;
        } else {
          error = true;
          return;
        }
      } else if (token.token == TokenEnum.openCommandBalise) {
        parseCommand(node: children, position: token.position!);
      } else {
        error = true;
        return;
      }
    }

    token = tokens[index];

    forCondition['startPosition'] = position;
    forCondition['endPosition'] = token.position;

    forCondition['children'] = children;

    node.add(forCondition);
  }
}
