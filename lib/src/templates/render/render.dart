import 'package:dartshine/src/templates/lexer/token.dart';

class Render {
  final List<Map<String, dynamic>> parserResult;
  final Map<String, dynamic> variableList;
  final List<String> sources;
  int padding = 0;
  bool error = false;

  Render(
      {required this.parserResult,
      required this.variableList,
      required this.sources});

  void render() {
    for (Map<String, dynamic> map in parserResult) {
      String data = '';

      if (map['type'] == 'variable') {
        data = variableRender(map['name']);

        int startPosition = map['startPosition'];
        int endPosition = map['endPosition'];

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      } else if (map['type'] == 'for') {
        data = forRender(map);

        int startPosition = map['startPosition'];
        int endPosition = map['endPosition'];

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      } else if (map['type'] == 'condition') {
        data = conditionRender(map);

        int startPosition = map['startPosition'];
        int endPosition = map['endPosition'];

        sources.replaceRange(
            startPosition + padding, endPosition + 1 + padding, data.split(''));

        padding += data.length - (endPosition + 1 - startPosition);
      }
    }
  }

  String variableRender(String variableName) {
    StringBuffer data = StringBuffer();
    String? value = variableList[variableName];

    if (value == null) {
      return "";
    }

    data.write(value);

    return data.toString();
  }

  String forRender(Map<String, dynamic> forParserResult) {
    StringBuffer data = StringBuffer();
    List<dynamic> values = variableList[forParserResult['collection']];

    for (dynamic value in values) {
      variableList[forParserResult['variable']] = value;

      List<Map<String, dynamic>> childrenList = forParserResult['children'];

      for (Map<String, dynamic> children in childrenList) {
        if (children['type'] == 'text') {
          data.write(children['value']);
        } else if (children['type'] == 'variable') {
          String result = variableRender(children['name']);
          data.write(result);
        }
      }
    }

    return data.toString();
  }

  String conditionRender(Map<String, dynamic> conditionParserResult) {
    StringBuffer data = StringBuffer();

    bool result =
        parseConditionResult(conditionList: conditionParserResult['condition']);

    List<Map<String, dynamic>> childrenList = [];

    if (result) {
      childrenList = conditionParserResult['trueCondition'];
    } else {
      childrenList = conditionParserResult['falseCondition'];
    }

    for (Map<String, dynamic> children in childrenList) {
      if (children['type'] == 'text') {
        data.write(children['value']);
      } else if (children['type'] == 'variable') {
        String result = variableRender(children['name']);
        data.write(result);
      }
    }

    return data.toString();
  }

  bool parseConditionResult({required List<Token> conditionList}) {
    bool result = false;

    if (conditionList.length < 3) {
      error = true;
      return false;
    }

    List<dynamic> condition = [];

    if (conditionList[0].token == TokenEnum.variableName) {
      condition.add(parseVariableCondition(variable: conditionList[0]));
    } else if (conditionList[0].token == TokenEnum.stringValue) {
      condition.add(conditionList[0].value);
    } else if (conditionList[0].token == TokenEnum.intValue) {
      condition.add(conditionList[0].value);
    } else {
      error = true;
      return false;
    }

    condition.add(conditionList[1]);

    if (conditionList[2].token == TokenEnum.variableName) {
      condition.add(parseVariableCondition(variable: conditionList[2]));
    } else if (conditionList[2].token == TokenEnum.stringValue) {
      condition.add(conditionList[2].value);
    } else if (conditionList[2].token == TokenEnum.intValue) {
      condition.add(conditionList[2].value);
    } else {
      error = true;
      return false;
    }

    try {
      result = parseCondition(conditionList: condition);
    } catch (e) {
      error = true;
      return false;
    }

    return result;
  }

  dynamic parseVariableCondition({required Token variable}) {
    dynamic result = variableList[variable.value];

    return result;
  }

  bool parseCondition({required List<dynamic> conditionList}) {
    bool result = false;

    switch (conditionList[1].value) {
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
