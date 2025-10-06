import '../serialization/status.dart';

class HttpResponse {
  final String httpVersion;
  final Status status;
  final Map<String, String> headers;
  late String response;
  String body;
  List<String> cookies;

  HttpResponse(
      {this.httpVersion = 'HTTP/1.1',
      required this.status,
      required this.headers,
      this.body = '',
      this.cookies = const []});

  void createResponse() {
    response = "$httpVersion ${statusToString(status)}\r\n";

    headers.forEach((key, value) => response += "$key: $value\r\n");

    if (cookies.isNotEmpty) {
      for (String cookie in cookies) {
        response += "$cookie\r\n";
      }
    }

    response += "\r\n";

    if (body.isNotEmpty) {
      response += body;
      response += "\r\n";
    }

    response += "\r\n";
  }
}
