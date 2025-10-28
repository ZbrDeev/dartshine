import 'dart:convert';
import 'dart:typed_data';
import '../serialization/struct.dart';

/// Used to describe the HTTP request
class HttpRequest {
  /// Method of the request
  final Method method;

  /// URI request path
  final String uri;

  /// HTTP version of the request
  final String httpVersion;

  /// HTTP body of the request
  Uint8List body = Uint8List(0);

  /// If the request is in MIME text format, the body will be here
  String text = "";

  /// If the request is in MIME application/json format, the body will be here
  Object? json;

  /// HTTP request headers
  final Map<String, String> headers;

  /// HTTP request parameters
  Map<String, String> parameters = {};

  /// HTTP request dynamic path values
  Map<String, String> dynamicPathValue = {};

  /// HTTP Client cookies
  Map<String, String> cookies = {};

  HttpRequest(this.method, this.uri, this.httpVersion, this.body, this.headers,
      this.parameters) {
    if (headers.containsKey("Cookie")) {
      cookies = parseCookie(headers["Cookie"]!);
      headers.remove("Cookie");
    }

    if (!headers.containsKey("Content-Type")) {
      return;
    }

    if (headers["Content-Type"]!.startsWith("text/")) {
      text = utf8.decode(body);
    } else if (headers["Content-Type"] == "application/json") {
      json = jsonDecode(utf8.decode(body));
    }
  }
}

Map<String, String> parseCookie(String cookies) {
  Map<String, String> parsedCookie = {};
  List<String> splittedCookie = cookies.split(";");

  for (String cookie in splittedCookie) {
    cookie = cookie.trim();
    List<String> cookieKeyValue = cookie.split("=");

    parsedCookie[cookieKeyValue[0]] = cookieKeyValue[1];
  }

  return parsedCookie;
}

HttpRequest? convert(Uint8List request) {
  int index = -1;

  for (int i = 0; i < request.length; ++i) {
    if (request[i] == 13 &&
        request[i + 1] == 10 &&
        request[i + 2] == 13 &&
        request[i + 3] == 10) {
      index = i;
      break;
    }
  }

  if (index == -1) {
    return null;
  }

  final String requestString = ascii.decode(request.sublist(0, index + 2));

  Map<String, String> headers = {};
  Map<String, String> parameters = {};

  List<String> requestSplit = requestString.split('\r\n');

  final List<String> methodRequest = requestSplit[0].split(' ');
  List<String> splittedUriParameters = methodRequest[1].split("?");

  final Method method = methodWithString(methodRequest[0]);
  final String uri = splittedUriParameters[0];
  final String httpVersion = methodRequest[2];
  requestSplit.removeAt(0);

  if (splittedUriParameters.length > 1) {
    for (String parameter in splittedUriParameters[1].split("&")) {
      List<String> parameterKeyValue = parameter.split("=");

      parameters[parameterKeyValue[0]] = parameterKeyValue[1];
    }
  }

  for (int i = 0; i < requestSplit.length; i++) {
    String data = requestSplit[i];

    if (data.isEmpty) {
      requestSplit.removeRange(0, i);
      break;
    }

    List<String> dataSplit = data.split(':');
    dataSplit[0] = dataSplit[0].trim();
    dataSplit[1] = dataSplit[1].trim();

    if (headers.containsKey(dataSplit[0])) {
      String value = headers[dataSplit[0]]!;
      value += ", ${dataSplit[1]}";
      headers[dataSplit[0]] = value;
    } else {
      headers[dataSplit[0]] = dataSplit[1];
    }
  }

  Uint8List body = Uint8List(0);

  if (headers.containsKey("Content-Length")) {
    body = request.sublist(
        index + 4, index + 4 + int.parse(headers["Content-Length"]!));
  }

  return HttpRequest(method, uri, httpVersion, body, headers, parameters);
}
