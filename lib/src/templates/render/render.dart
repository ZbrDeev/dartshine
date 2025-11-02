import 'package:dartshine/src/error/template_error.dart';
import 'package:dartshine/src/forms/forms.dart';
import 'package:dartshine/src/templates/parser/ast.dart';

class Render {
  final AstRoot root;
  final Map<String, dynamic> variableList;
  final List<String> sources;
  final String filename;
  int padding = 0;

  Render(
      {required this.root,
      required this.variableList,
      required this.sources,
      required this.filename});

  void render() {
    for (AstNode node in root.nodes) {
      String data = '';

      if (node is VariableAst) {
        data = variableRender(node);

        int startPosition = node.startPosition;
        int endPosition = node.endPosition;

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      } else if (node is ForAst) {
        data = forRender(node);

        int startPosition = node.startPosition;
        int endPosition = node.endPosition;

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      } else if (node is ConditionAst) {
        data = conditionRender(node);

        int startPosition = node.startPosition;
        int endPosition = node.endPosition;

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      } else if (node is MemberAst) {
        data = memberRender(node);

        int startPosition = node.startPosition;
        int endPosition = node.endPosition;

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      }
    }
  }

  String memberRender(MemberAst ast) {
    dynamic value = variableList[ast.member.first];

    for (int i = 1; i < ast.member.length; ++i) {
      dynamic member = ast.member[i];

      if (member is String) {
        value = (value as Map<String, dynamic>)[member];
      } else if (member is int) {
        value = (value as List<dynamic>)[member];
      }
    }

    return value.toString();
  }

  String variableRender(VariableAst ast) {
    StringBuffer data = StringBuffer();
    dynamic value = variableList[ast.name];

    if (value == null) {
      return "";
    } else if (value is DartshineForms) {
      data.write(value.toHtml());
    } else {
      data.write(value);
    }

    return data.toString();
  }

  String forRender(ForAst ast) {
    StringBuffer data = StringBuffer();
    List<dynamic> values = variableList[ast.collection];

    for (dynamic value in values) {
      variableList[ast.variable] = value;

      List<AstNode> childrenList = ast.children;

      for (AstNode children in childrenList) {
        if (children is TextAst) {
          data.write(children.value);
        } else if (children is VariableAst) {
          data.write(variableRender(children));
        } else if (children is ConditionAst) {
          data.write(conditionRender(children));
        } else if (children is MemberAst) {
          data.write(memberRender(children));
        }
      }
    }

    return data.toString();
  }

  String conditionRender(ConditionAst ast) {
    StringBuffer data = StringBuffer();

    List<AstNode> childrenList = [];

    if (parseConditionResult(conditionList: ast.condition)) {
      childrenList = ast.consequent;
    } else {
      childrenList = ast.alternate;
    }

    for (AstNode children in childrenList) {
      if (children is TextAst) {
        data.write(children.value);
      } else if (children is VariableAst) {
        data.write(variableRender(children));
      } else if (children is ForAst) {
        data.write(forRender(children));
      } else if (children is MemberAst) {
        data.write(children);
      }
    }

    return data.toString();
  }

  bool parseConditionResult({required List<AstNode> conditionList}) {
    bool result = false;

    if (conditionList.length < 3) {
      throw InvalidOperator(
          filename: filename,
          column: conditionList[0].column,
          line: conditionList[0].line);
    }

    List<dynamic> condition = [];

    if (conditionList[0] is VariableAst) {
      condition.add(
          parseVariableCondition(variable: (conditionList[0] as VariableAst)));
    } else if (conditionList[0] is MemberAst) {
      condition.add(memberRender(conditionList[0] as MemberAst));
    } else if (conditionList[0] is ValueAst) {
      ValueAst valueAst = (conditionList[0] as ValueAst);

      if (valueAst.type == ValueTypeAst.string) {
        condition.add(valueAst.value);
      } else if (valueAst.type == ValueTypeAst.integer) {
        condition.add(int.parse(valueAst.value));
      } else {
        throw InvalidValueType(
            filename: filename, column: valueAst.column, line: valueAst.line);
      }
    } else {
      throw InvalidValueType(
          filename: filename,
          column: conditionList[0].column,
          line: conditionList[0].line);
    }

    condition.add(conditionList[1]);

    if (conditionList[2] is VariableAst) {
      condition.add(
          parseVariableCondition(variable: (conditionList[2] as VariableAst)));
    } else if (conditionList[2] is MemberAst) {
      condition.add(memberRender(conditionList[2] as MemberAst));
    } else if (conditionList[2] is ValueAst) {
      ValueAst valueAst = (conditionList[2] as ValueAst);

      if (valueAst.type == ValueTypeAst.string) {
        condition.add(valueAst.value);
      } else if (valueAst.type == ValueTypeAst.integer) {
        condition.add(int.parse(valueAst.value));
      } else {
        throw InvalidValueType(
            filename: filename, column: valueAst.column, line: valueAst.line);
      }
    } else {
      throw InvalidValueType(
          filename: filename,
          column: conditionList[2].column,
          line: conditionList[2].line);
    }

    try {
      result = parseCondition(conditionList: condition);
    } catch (e) {
      throw InvalidOperator(
          filename: filename,
          column: conditionList[1].column,
          line: conditionList[1].line);
    }

    return result;
  }

  dynamic parseVariableCondition({required VariableAst variable}) {
    dynamic result = variableList[variable.name];

    return result;
  }

  bool parseCondition({required List<dynamic> conditionList}) {
    bool result = false;

    switch (conditionList[1].operator) {
      case '==':
        result = conditionList[0] == conditionList[2];
        break;
      case '!=':
        result = conditionList[0] != conditionList[2];
        break;
      case '<=':
        result = conditionList[0] <= conditionList[2];
        break;
      case '>=':
        result = conditionList[0] >= conditionList[2];
        break;
      case '<':
        result = conditionList[0] < conditionList[2];
        break;
      case '>':
        result = conditionList[0] > conditionList[2];
        break;
    }

    return result;
  }
}
