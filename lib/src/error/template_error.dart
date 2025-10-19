import 'package:dartshine/src/templates/lexer/token.dart';

class NotImplemented extends Error {
  NotImplemented();

  @override
  String toString() {
    return 'Feature not yet implemented';
  }
}

class InvalidBaliseToken extends Error {
  InvalidBaliseToken();

  @override
  String toString() {
    return 'Invalid open balise token';
  }
}

class InvalidCommandToken extends Error {
  TokenEnum tokenEnum;

  InvalidCommandToken({required this.tokenEnum});

  @override
  String toString() {
    return 'Invalid command token. Expected "for" or "if", but got: $tokenEnum';
  }
}

class InvalidVariableName extends Error {
  TokenEnum tokenEnum;

  InvalidVariableName({required this.tokenEnum});

  @override
  String toString() {
    return 'You have used a reserved token $tokenEnum';
  }
}

class InvalidCloseBalise extends Error {
  bool isCommand;

  InvalidCloseBalise({required this.isCommand});

  @override
  String toString() {
    if (isCommand) {
      return 'Invalid close command balise';
    }

    return 'Invalid close variable balise';
  }
}

class InvalidCloseBrace extends Error {
  InvalidCloseBrace();

  @override
  String toString() {
    return 'Invalid close brace';
  }
}

class InvalidIfCondition extends Error {
  TokenEnum tokenEnum;

  InvalidIfCondition({required this.tokenEnum});

  @override
  String toString() {
    return 'Expect "\$>", operator, string value, integer value or variable name but got: $tokenEnum';
  }
}

class InvalidForInCondition extends Error {
  TokenEnum tokenEnum;

  InvalidForInCondition({required this.tokenEnum});

  @override
  String toString() {
    return 'Expect in but got: $tokenEnum';
  }
}
