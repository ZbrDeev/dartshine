import 'dart:convert';
import 'dart:typed_data';
import '../serialization/struct.dart';

class HttpRequest {
  final Method method;
  final String uri;
  final String httpVersion;
  String body = "";
  final Map<String, String> headers;
  Map<String, String> parameters = {};

  HttpRequest(this.method, this.uri, this.httpVersion, this.body, this.headers,
      this.parameters);
}

HttpRequest convert(Uint8List request) {
  final String requestString = utf8.decode(request);
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
    dataSplit[0].trim();
    dataSplit[1].trim();
    headers[dataSplit[0]] = dataSplit[1];
  }

  String body = "";

  if (requestSplit.isNotEmpty) {
    body = requestSplit.join();
  }

  return HttpRequest(method, uri, httpVersion, body, headers, parameters);
}
