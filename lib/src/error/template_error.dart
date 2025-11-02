import 'package:dartshine/src/templates/lexer/token.dart';

class NotImplemented extends Error {
  final String filename;
  final int column;
  final int line;
  NotImplemented(
      {required this.filename, required this.column, required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Feature not yet implemented';
  }
}

class InvalidBaliseToken extends Error {
  final String filename;
  final int column;
  final int line;
  InvalidBaliseToken(
      {required this.filename, required this.column, required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Invalid open balise token';
  }
}

class InvalidCommandToken extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidCommandToken(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Invalid command token. Expected "for" or "if", but got: $tokenEnum';
  }
}

class InvalidVariableName extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidVariableName(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column You have used a reserved token $tokenEnum';
  }
}

class InvalidCloseBalise extends Error {
  final String filename;
  final int column;
  final int line;
  bool isCommand;

  InvalidCloseBalise(
      {required this.isCommand,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    if (isCommand) {
      return '$filename:$line:$column Invalid close command balise';
    }

    return '$filename:$line:$column Invalid close variable balise';
  }
}

class InvalidCloseBrace extends Error {
  final String filename;
  final int column;
  final int line;
  InvalidCloseBrace(
      {required this.filename, required this.column, required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Invalid close brace';
  }
}

class InvalidIfCondition extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidIfCondition(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Expect operator, string value, integer value or variable name but got: $tokenEnum';
  }
}

class InvalidForInCondition extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidForInCondition(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Expect "in" but got: $tokenEnum';
  }
}

class InvalidOperator extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum? tokenEnum;

  InvalidOperator(
      {this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    if (tokenEnum != null) {
      return '$filename:$line:$column Expect operator but got: $tokenEnum';
    } else {
      return '$filename:$line:$column Expect operator';
    }
  }
}

class InvalidIntegerValue extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidIntegerValue(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Expect integer value but got: $tokenEnum';
  }
}

class InvalidCloseBracket extends Error {
  final String filename;
  final int column;
  final int line;
  TokenEnum tokenEnum;

  InvalidCloseBracket(
      {required this.tokenEnum,
      required this.filename,
      required this.column,
      required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Expect "]" but got: $tokenEnum';
  }
}

class InvalidValueType extends Error {
  final String filename;
  final int column;
  final int line;

  InvalidValueType(
      {required this.filename, required this.column, required this.line});

  @override
  String toString() {
    return '$filename:$line:$column Expect integer value, string value or variable name';
  }
}
