import 'package:dartshine/src/error/template_error.dart';
import 'package:dartshine/src/templates/lexer/token.dart';
import 'package:dartshine/src/templates/parser/ast.dart';

class Parser {
  final AstRoot root = AstRoot();
  int index = 0;
  final List<Token> tokens;
  final String filename;

  Parser({required this.tokens, required this.filename});

  void parser() {
    for (; index < tokens.length; ++index) {
      Token token = tokens[index];

      if (token.token == TokenEnum.openCommandBalise) {
        root.nodes.add(parseCommand(position: token.position!));
      } else if (token.token == TokenEnum.openVariableBalise) {
        root.nodes.add(parseVariable(position: token.position!));

        if (tokens[index].token != TokenEnum.closeVariableBalise) {
          throw InvalidCloseBalise(
              isCommand: false,
              filename: filename,
              line: tokens[index].line,
              column: tokens[index].column);
        }
      }
    }
  }

  AstNode parseCommand({required int position}) {
    Token token = tokens[++index];

    if (token.token == TokenEnum.ifCommand) {
      return parseCondition(position: position);
    } else if (token.token == TokenEnum.forCommand) {
      return parseFor(position: position);
    } else {
      throw InvalidCommandToken(
          tokenEnum: token.token,
          filename: filename,
          line: token.line,
          column: token.column);
    }
  }

  int _parseBracket() {
    String number = "";

    if (tokens[++index].token != TokenEnum.intValue) {
      throw InvalidIntegerValue(
          tokenEnum: tokens[index].token,
          filename: filename,
          column: tokens[index].column,
          line: tokens[index].line);
    }

    number = tokens[index].value!;

    if (tokens[++index].token != TokenEnum.closeBracket) {
      throw InvalidCloseBracket(
          tokenEnum: tokens[index].token,
          filename: filename,
          column: tokens[index].column,
          line: tokens[index].line);
    }

    return int.parse(number);
  }

  AstNode parseVariable({required int position}) {
    Token token = tokens[++index];
    AstNode result;
    List<dynamic> variableList = [];

    for (; index < tokens.length; ++index) {
      token = tokens[index];

      if (token.token == TokenEnum.variableName) {
        variableList.add(token.value);
      } else if (token.token == TokenEnum.dot) {
        continue;
      } else if (token.token == TokenEnum.openBracket) {
        variableList.add(_parseBracket());
      } else {
        break;
      }
    }

    if (variableList.length > 1) {
      MemberAst ast = MemberAst();
      ast.member = variableList;
      result = ast;
    } else if (variableList.length == 1 && variableList.first is! int) {
      VariableAst ast = VariableAst();
      ast.name = variableList.first;
      result = ast;
    } else {
      throw InvalidVariableName(
          tokenEnum: token.token,
          filename: filename,
          line: token.line,
          column: token.column);
    }

    token = tokens[index];

    result.startPosition = position;
    result.endPosition = token.position!;

    return result;
  }

  ValueAst parseValue() {
    ValueAst ast = ValueAst();
    Token token = tokens[index];

    if (token.token == TokenEnum.intValue) {
      ast.type = ValueTypeAst.integer;
    } else if (token.token == TokenEnum.stringValue) {
      ast.type = ValueTypeAst.string;
    } else {
      throw Error();
    }

    ast.value = token.value!;

    return ast;
  }

  OperatorAst parseOperator() {
    Token token = tokens[index];
    OperatorAst ast = OperatorAst();

    if (token.token != TokenEnum.operator) {
      throw InvalidOperator(
          tokenEnum: token.token,
          filename: filename,
          column: token.column,
          line: token.line);
    }

    ast.operator = token.value!;

    return ast;
  }

  List<AstNode> parseIfCondition() {
    List<AstNode> conditionList = [];

    while (true) {
      Token token = tokens[++index];

      if (token.token == TokenEnum.closeCommandBalise) {
        break;
      } else if (token.token == TokenEnum.variableName) {
        conditionList.add(parseVariable(position: token.position!));
      } else if (token.token == TokenEnum.operator) {
        conditionList.add(parseOperator());
      } else if (token.token == TokenEnum.intValue ||
          token.token == TokenEnum.stringValue) {
        conditionList.add(parseValue());
      } else {
        throw InvalidIfCondition(
            tokenEnum: token.token,
            filename: filename,
            line: token.line,
            column: token.column);
      }
    }

    return conditionList;
  }

  AstNode parseCondition({required int position}) {
    ConditionAst ast = ConditionAst();
    Token token = tokens[index];
    bool condition = true;

    ast.condition = parseIfCondition();

    List<AstNode> children = [];

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
        index += 2;
        ast.consequent = children;
        children = [];
        condition = false;
      } else if (token.token == TokenEnum.openVariableBalise) {
        children.add(parseVariable(position: token.position!));
      } else if (token.token == TokenEnum.openCommandBalise) {
        children.add(parseCommand(position: token.position!));
      } else if (token.token == TokenEnum.content) {
        children.add(TextAst(value: token.value!));
      }

      ++index;
    }

    token = tokens[index];

    ast.startPosition = position;
    ast.endPosition = token.position!;

    if (condition) {
      ast.consequent = children;
    } else {
      ast.alternate = children;
    }

    return ast;
  }

  ForAst parseFor({required int position}) {
    ForAst ast = ForAst();
    Token token = tokens[++index];

    if (token.token != TokenEnum.variableName) {
      throw InvalidVariableName(
          tokenEnum: token.token,
          filename: filename,
          line: token.line,
          column: token.column);
    }

    ast.variable = token.value!;

    token = tokens[++index];

    if (token.token != TokenEnum.inCommand) {
      throw InvalidForInCondition(
          tokenEnum: token.token,
          filename: filename,
          line: token.line,
          column: token.column);
    }

    token = tokens[++index];

    if (token.token != TokenEnum.variableName) {
      throw InvalidVariableName(
          tokenEnum: token.token,
          filename: filename,
          line: token.line,
          column: token.column);
    }

    ast.collection = token.value!;

    if (tokens[++index].token != TokenEnum.closeCommandBalise) {
      throw InvalidCloseBalise(
          isCommand: true,
          filename: filename,
          line: token.line,
          column: token.column);
    }

    List<AstNode> children = [];

    while (true) {
      token = tokens[++index];

      if (token.token == TokenEnum.openCommandBalise &&
          tokens[index + 1].token == TokenEnum.endForCommand &&
          tokens[index + 2].token == TokenEnum.closeCommandBalise) {
        index += 2;
        break;
      } else if (token.token == TokenEnum.openVariableBalise) {
        children.add(parseVariable(position: token.position!));
      } else if (token.token == TokenEnum.content) {
        children.add(TextAst(value: token.value!));
      } else if (token.token == TokenEnum.openCommandBalise) {
        children.add(parseCommand(position: token.position!));
      } else {
        throw InvalidBaliseToken(
            filename: filename, line: token.line, column: token.column);
      }
    }

    token = tokens[index];

    ast.startPosition = position;
    ast.endPosition = token.position!;

    ast.children = children;

    return ast;
  }
}
