import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../serialization/response.dart';
import '../serialization/status.dart';
import '../serialization/request.dart';
import 'package:mime/mime.dart';

class PublicHandler {
  final Socket _client;
  final HttpRequest request;

  const PublicHandler(this._client, this.request);

  void sendHtml(String file, Status status, Map<String, String> headers) {
    headers['Content-Type'] = 'text/html';
    headers['Content-Length'] = '${file.length}';

    HttpResponse response =
        HttpResponse(status: status, headers: headers, body: file);
    response.createResponse();

    _client.write(response.response);
    _client.close();
  }

  void sendStatus(Status status) {
    HttpResponse response = HttpResponse(headers: {}, status: status);
    response.createResponse();

    _client.write(response.response);
    _client.close();
  }

  Future<void> sendFile(Status status, File file) async {
    Map<String, String> headers = {};
    headers['Content-Type'] = lookupMimeType(file.path)!;
    headers['Content-Length'] = '${file.length}';
    Uint8List data = await file.readAsBytes();

    HttpResponse response = HttpResponse(status: status, headers: headers);
    response.createResponse();

    _client.write(response.response);
    _client.add(data);
    _client.close();
  }

  void send(Status status, Map<String, String> headers, String dataType,
      dynamic body) {
    headers['Content-Length'] = '${body.length}';

    HttpResponse response = HttpResponse(status: status, headers: headers);

    if (body is String) {
      response.body = body;
      response.createResponse();
      _client.write(response.response);
      _client.close();
    } else if (body is Uint8List) {
      response.createResponse();
      _client.write(response.response);
      _client.add(body);
      _client.close();
    } else {
      throw TypeError();
    }
  }
}
