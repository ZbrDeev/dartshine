import 'dart:convert';
import 'dart:typed_data';

Map<String, String> parseFormUrlEncoding(String form) {
  if (form.isEmpty) {
    return {};
  }

  Map<String, String> parsedForm = {};

  for (String value in form.split("&")) {
    List<String> keyValue = value.split("=");
    keyValue[0] = keyValue[0].trim();

    if (parsedForm.containsKey(keyValue[0])) {
      String value = parsedForm[keyValue[0]]!;
      value += ",${keyValue[1]}";
      parsedForm[keyValue[0]] = value;
    } else {
      parsedForm[keyValue[0]] = keyValue[1];
    }
  }

  return parsedForm;
}

class FormFile {
  final String filename;
  final String contentType;
  final Uint8List data;

  FormFile(
      {required this.filename, required this.contentType, required this.data});
}

class FormData {
  Map<String, String> fields = {};
  Map<String, FormFile> files = {};
  String boundary = "";
  String contentType;
  Uint8List form;

  FormData({required this.contentType, required this.form});

  void _parseSingleField(int index) {
    Map<String, String> fieldHeader = {};
    Uint8List body = Uint8List(0);

    int startPoint = index;

    for (int i = index; i < form.length; ++i) {
      if (form[i] == 13 &&
          form[i + 1] == 10 &&
          form[i + 2] == 13 &&
          form[i + 3] == 10) {
        List<String> parsedHeader =
            utf8.decode(form.sublist(startPoint, i)).split(":");
        fieldHeader[parsedHeader[0]] = parsedHeader[1];
        startPoint = i + 4;
        break;
      } else if (form[i] == 13 && form[i + 1] == 10) {
        List<String> parsedHeader =
            utf8.decode(form.sublist(startPoint, i)).split(":");
        fieldHeader[parsedHeader[0]] = parsedHeader[1];
        startPoint = i + 2;
      }
    }

    for (int i = startPoint; i < form.length; ++i) {
      if (form[i] == 13 &&
          form[i + 1] == 10 &&
          form[i + 2] == 13 &&
          form[i + 3] == 10) {
        break;
      } else if (form[i] == 13 && form[i + 1] == 10) {
        body = form.sublist(startPoint, i);
        break;
      }
    }

    if (!fieldHeader.containsKey("Content-Disposition")) {
      // TODO: HANDLE ERROR
      return;
    }

    String contentDisposition = fieldHeader["Content-Disposition"]!;

    RegExpMatch? nameRegex =
        RegExp(r'name="([^\s;]+)"').firstMatch(contentDisposition);
    RegExpMatch? filenameRegex =
        RegExp(r'filename="([^\s;]+)"').firstMatch(contentDisposition);

    if (nameRegex == null) {
      // TODO: HANDLE ERROR

      return;
    }

    String name = nameRegex.group(1)!;

    if (filenameRegex != null) {
      if (!fieldHeader.containsKey("Content-Type")) {
        // TODO: HANDLE ERROR
        return;
      }

      files[name] = FormFile(
          filename: filenameRegex.group(1)!,
          contentType: fieldHeader["Content-Type"]!,
          data: body);
    } else {
      fields[name] = utf8.decode(body);
    }
  }

  bool _checkBoundary(int index) {
    Uint8List boundaryInt = utf8.encode(boundary);

    for (int i = 0; i < boundary.length; ++i) {
      if (form[index + 4 + i] != boundaryInt[i]) {
        return false;
      }
    }

    return true;
  }

  void parseFormFormData() {
    RegExpMatch? boundaryRegex =
        RegExp(r'boundary=([^\s;]+)').firstMatch(contentType);

    if (boundaryRegex == null) {
      // TODO: HANDLE ERROR
      return;
    }

    boundary = boundaryRegex.group(1)!;

    for (int i = 0; i < form.length; ++i) {
      if (form[i] == 45 &&
          form[i + 1] == 45 &&
          form[i + 2] == 13 &&
          form[i + 3] == 10) {
        break;
      } else if (form[i] == 13 &&
          form[i + 1] == 10 &&
          form[i + 2] == 45 &&
          form[i + 3] == 45 &&
          _checkBoundary(i)) {
        i += boundary.length;

        if (form[i] == 45 &&
            form[i + 1] == 45 &&
            form[i + 2] == 13 &&
            form[i + 3] == 10) {
          break;
        }

        i += 6;

        _parseSingleField(i);
      }
    }
  }
}
