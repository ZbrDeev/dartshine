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
  stringValue
}

class Token {
  final TokenEnum token;
  final String? value;
  final int? position;

  Token({required this.token, this.value, this.position});
}
