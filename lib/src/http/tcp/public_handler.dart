import 'dart:io';
import 'dart:typed_data';
import '../serialization/response.dart';
import '../serialization/status.dart';
import '../serialization/request.dart';

class PublicHandler {
  final Socket _client;
  final HttpRequest request;

  const PublicHandler(this._client, this.request);

  Future<void> send(Status status, Map<String, String> headers, String dataType,
      dynamic body, List<String> cookies) async {
    if (body.length > 0) {
      headers['Content-Length'] = '${body.length}';
    }

    HttpResponse response =
        HttpResponse(status: status, headers: headers, cookies: cookies);

    if (body is String) {
      response.body = body;
      response.createResponse();
      _client.write(response.response);
      await _client.close();
    } else if (body is Uint8List) {
      response.createResponse();
      _client.write(response.response);
      _client.add(body);
      await _client.close();
    } else {
      throw TypeError();
    }
  }
}
