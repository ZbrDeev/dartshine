Map<String, String> parseForm(String? form) {
  if (form == null || form.isEmpty) {
    return {};
  }

  Map<String, String> parsedForm = {};

  for (String value in form.split("&")) {
    List<String> keyValue = value.split("=");

    parsedForm[keyValue[0]] = keyValue[1];
  }

  return parsedForm;
}
