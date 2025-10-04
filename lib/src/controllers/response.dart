import 'package:dartshine/src/http/serialization/response.dart';
import 'package:dartshine/src/http/serialization/status.dart';

class Response {
  final Status status;
  final dynamic body;
  final Map<String, String> headers;
  final String dataType;
  late HttpResponse response;

  Response(
      {required this.status,
      required this.body,
      required this.headers,
      this.dataType = 'text/html'}) {
    headers['Content-Type'] = dataType;

    if (body is String) {
      response = HttpResponse(status: status, headers: headers, body: body);
    } else {
      response = HttpResponse(status: status, headers: headers);
    }
  }
}
