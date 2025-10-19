import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartshine/src/http/serialization/parse_form.dart';
import 'package:dartshine/src/http/serialization/request.dart';

typedef CustomValidateFunction = String? Function(String value);

/// **Validator** is used to validate a field.
class Validator {
  /// Make the field valid
  bool isRequired;

  /// The minimum length of the field
  int minLength;

  /// The maximum length of the field
  int maxLength;

  /// Custom regex for the field
  RegExp? regex;

  /// A list of custom test functions
  List<CustomValidateFunction> customFunction;

  String error = "";

  Validator(
      {this.isRequired = false,
      this.minLength = -1,
      this.maxLength = -1,
      this.regex,
      this.customFunction = const []});

  bool validate(String value) {
    if (isRequired && value.isEmpty) {
      error = "You have to put some value";
      return false;
    }

    if (minLength > -1 && value.length < minLength) {
      error = "Value smaller than the required minimum length";
      return false;
    }

    if (maxLength > -1 && value.length > maxLength) {
      error = "Value bigger than the required maximum length";
      return false;
    }

    if (regex != null && !regex!.hasMatch(value)) {
      error = "Error with the regex";
      return false;
    }

    for (CustomValidateFunction function in customFunction) {
      String? result = function(value);

      if (result != null) {
        error = result;
        return false;
      }
    }

    return true;
  }

  String toHtml() {
    StringBuffer data = StringBuffer();

    if (minLength > 0) {
      data.write(' minlength="$minLength"');
    }

    if (maxLength > 0) {
      data.write(' maxlength="$minLength"');
    }

    if (isRequired) {
      data.write(' required');
    }

    return data.toString();
  }
}

abstract class Field {
  final Validator validator;
  String error = "";
  String value = "";

  Field({required this.validator});

  bool test(String value);

  String toHtml(String name);
}

class TextField extends Field {
  TextField({required super.validator});

  @override
  bool test(String value) {
    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="text" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

class MailField extends Field {
  static RegExp mailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

  MailField({required super.validator});

  @override
  bool test(String value) {
    if (!mailRegex.hasMatch(value)) {
      error = "Invalide mail format";
      return false;
    }

    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="email" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

class PasswordField extends Field {
  PasswordField({required super.validator});

  @override
  bool test(String value) {
    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="password" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

/// Field for integer data type
class IntegerField extends Field {
  static RegExp integerRegex = RegExp(r"^\d+$");

  IntegerField({required super.validator});

  @override
  bool test(String value) {
    if (!integerRegex.hasMatch(value)) {
      error = "Invalid Integer";
      return false;
    }

    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="number" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

/// Field for floating-point data type
class FloatField extends Field {
  static RegExp floatRegex = RegExp(r"^[+-]?([0-9]*[.])?[0-9]+$");

  FloatField({required super.validator});

  @override
  bool test(String value) {
    if (!floatRegex.hasMatch(value)) {
      error = "Invalid Float Number";
      return false;
    }

    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="number" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

/// Field for both integer and floating-point data types
class NumberField extends Field {
  NumberField({required super.validator});

  @override
  bool test(String value) {
    if (double.tryParse(value) == null) {
      error = "Invalid Number";
      return false;
    }

    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="number" name="$name" id="id_$name"');
    data.write(validator.toHtml());
    data.write('>');

    return data.toString();
  }
}

/// Field for single choice
class ChoiceField extends Field {
  final Map<String, String> choices;

  ChoiceField({required this.choices, required super.validator});

  @override
  bool test(String value) {
    if (!validator.validate(value)) {
      error = validator.error;
      return false;
    }

    if (!choices.containsKey(value)) {
      error = "Invalid value";
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<select name="$name" id="id_$name">\n');

    for (String key in choices.keys) {
      data.write('<option value="$key">${choices[key]}</option>\n');
    }

    data.write('</select>');

    return data.toString();
  }
}

/// Field for multiple choices
class MultipleChoicesField extends Field {
  final Map<String, String> choices;

  MultipleChoicesField({required this.choices, required super.validator});

  @override
  bool test(String values) {
    List<String> valuesSplitted = values.split(",");

    for (String value in valuesSplitted) {
      if (!choices.containsKey(value)) {
        return false;
      }
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<select name="$name" id="id_$name" multiple>\n');

    for (String key in choices.keys) {
      data.write('<option value="$key">${choices[key]}</option>\n');
    }

    data.write('</select>');

    return data.toString();
  }
}

/// Field for boolean value
class BooleanField extends Field {
  final bool checked;

  BooleanField({this.checked = false, required super.validator});

  @override
  bool test(String value) {
    if (value != "on") {
      return false;
    }

    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="checkbox" name="$name" id="id_$name"');

    if (checked) {
      data.write(' checked');
    }

    data.write('>\n');

    return data.toString();
  }
}

/// Field for file data type
class FileField extends Field {
  /// If you want to upload to a directory
  String? uploadTo;

  FileField({required super.validator, this.uploadTo});

  @override
  bool test(String value) {
    return true;
  }

  @override
  String toHtml(String name) {
    StringBuffer data = StringBuffer();

    data.write('<input type="file" name="$name" id="id_$name">\n');

    return data.toString();
  }

  void createFile(String filename, Uint8List data) {
    if (uploadTo == null) {
      return;
    }

    File("$uploadTo/$filename").create().then((File file) {
      file.writeAsBytesSync(data);
    });
  }
}

/// **DartshineForms** is used for managing forms with fields, you can create fields in fields variable.
/// This class provides a validate method with `isValid(HttpRequest request)` where request is the request you received in your controller.
class DartshineForms {
  /// You can create fields here
  Map<String, Field> fields = {};

  bool _isValidUrlEncoding(Uint8List form) {
    Map<String, String> parsedForm = parseFormUrlEncoding(utf8.decode(form));

    for (String key in parsedForm.keys) {
      if (key == "csrf_token") {
        continue;
      }

      if (!fields.containsKey(key)) {
        return false;
      }

      if (!fields[key]!.test(parsedForm[key]!)) {
        return false;
      }

      fields[key]!.value = parsedForm[key]!;
    }

    return true;
  }

  bool _isValidFormData(String contentType, Uint8List form) {
    FormData formData = FormData(contentType: contentType, form: form);
    formData.parseFormFormData();

    if (formData.error) {
      return false;
    }

    for (String key in formData.fields.keys) {
      if (key == "csrf_token") {
        continue;
      }

      if (!fields.containsKey(key)) {
        return false;
      }

      if (!fields[key]!.test(formData.fields[key]!)) {
        return false;
      }

      fields[key]!.value = formData.fields[key]!;
    }

    for (String key in formData.files.keys) {
      if (key != "csrf_token" &&
          !fields.containsKey(key) &&
          !formData.files.containsKey(key)) {
        return false;
      }

      (fields[key]! as FileField)
          .createFile(formData.files[key]!.filename, formData.files[key]!.data);
    }

    return true;
  }

  /// Used to validate the form
  bool isValid(HttpRequest request) {
    if (!request.headers.containsKey("Content-Type")) {
      return false;
    }

    if (request.headers["Content-Type"] ==
        "application/x-www-form-urlencoded") {
      return _isValidUrlEncoding(request.body);
    } else if (request.headers["Content-Type"]!
        .contains("multipart/form-data")) {
      return _isValidFormData(request.headers["Content-Type"]!, request.body);
    } else {
      return false;
    }
  }

  String toHtml() {
    StringBuffer data = StringBuffer();

    for (String key in fields.keys) {
      data.write(
          '<label for="id_$key">${key.replaceFirst(key[0], key[0].toUpperCase())}:</label>');

      data.write(fields[key]!.toHtml(key));
    }

    return data.toString();
  }
}
