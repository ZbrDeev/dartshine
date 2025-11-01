enum ValueTypeAst { integer, string }

class AstRoot {
  List<AstNode> nodes = [];
}

abstract class AstNode {
  int startPosition = 0;
  int endPosition = 0;

  int column = 1;
  int line = 1;
}

class MemberAst extends AstNode {
  List<dynamic> member = [];
}

class VariableAst extends AstNode {
  String name = "";
}

class ValueAst extends AstNode {
  String value = "";
  ValueTypeAst type = ValueTypeAst.string;
}

class TextAst extends AstNode {
  String value = "";

  TextAst({required this.value});
}

class OperatorAst extends AstNode {
  String operator = "";
}

class ConditionAst extends AstNode {
  List<AstNode> condition = [];
  List<AstNode> consequent = [];
  List<AstNode> alternate = [];
}

class ForAst extends AstNode {
  String variable = "";
  String collection = "";
  List<AstNode> children = [];
}
