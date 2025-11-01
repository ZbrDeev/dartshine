enum TokenEnum {
  openVariableBalise,
  closeVariableBalise,
  openCommandBalise,
  closeCommandBalise,
  variableName,
  forCommand,
  inCommand,
  endForCommand,
  ifCommand,
  elseCommand,
  endIfCommand,
  content,
  operator,
  intValue,
  stringValue,
  dot,
  openBracket,
  closeBracket
}

class Token {
  final TokenEnum token;
  final String? value;
  final int? position;

  final int line;
  final int column;

  Token(
      {required this.token,
      required this.column,
      required this.line,
      this.value,
      this.position});
}
