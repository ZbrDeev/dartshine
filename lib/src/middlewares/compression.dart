import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/middlewares/middleware.dart';

Future<Response> compress(
    HttpRequest request, MiddlewareNextFunction next) async {
  Response response = await next(request);

  if (response.body is Uint8List || response.body is String) {
    if (request.headers.containsKey("Accept-Encoding") &&
        request.headers["Accept-Encoding"]!.contains(RegExp("gzip"))) {
      const gzip = GZipEncoder();

      response.headers["Content-Encoding"] = "gzip";

      response.body = gzip.encodeBytes(response.body is Uint8List
          ? response.body
          : (response.body as String).codeUnits);
    }
  }

  return response;
}
