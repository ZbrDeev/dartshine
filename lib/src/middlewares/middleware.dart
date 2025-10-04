import 'package:dartshine/src/controllers/controllers.dart';
import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';
import 'package:dartshine/src/http/tcp/public_handler.dart';
import 'package:dartshine/src/routes/routes.dart';

import 'dart:io';

import 'package:mime/mime.dart';

// TODO: HANDLE RETURN DEFAULT VALUE FOR EXAMPLE WITH ERROR404, INTERNAL ERROR, ETC

typedef ResponseFunction = Future<Response?> Function(HttpRequest request);

class DartshineMiddleware {
  final List<ResponseFunction> middleware = [];

  late DartshineRoute _routes;

  void handleMiddleware(
      PublicHandler handler, HttpRequest request, DartshineRoute routes) async {
    _routes = routes;

    for (var i = 0; i < middleware.length; ++i) {
      Response? response = await middleware[i](request);

      if (response != null) {
        handler.send(response.status, response.headers, response.dataType,
            response.body);
        return;
      } else {
        continue;
      }
    }
  }

  Future<Response?> onRequest(HttpRequest request) async {
    String uri = request.uri;

    if (uri.contains(
      RegExp(
        r'\.(html|htm|css|js|json|xml|txt|csv|jpg|jpeg|png|gif|svg|webp|ico|bmp|tiff|tif|mp4|webm|ogg|mov|avi|mkv|mp3|wav|m4a|aac|woff|woff2|ttf|otf|eot|pdf|zip|rar)$',
      ),
    )) {
      if (uri.startsWith('/')) {
        uri = uri.substring(1);
      }

      File file = File(uri);

      if (await file.exists()) {
        // TODO: HANDLE DATA TYPE

        Response response = Response(
            status: Status.ok,
            headers: {},
            dataType: lookupMimeType(file.path)!,
            body: await file.readAsBytes());

        return response;
      } else {
        return Response(
            status: Status.notFound,
            headers: {},
            dataType: 'text/html',
            body: '');
      }
    } else {
      Response response = findRoutes(request);
      return response;
    }
  }

  Response findRoutes(HttpRequest request) {
    Map<String, dynamic> route = _routes.findUrl(request.uri);

    if (route.isEmpty) {
      return Response(
          status: Status.notFound,
          headers: {},
          dataType: 'text/html',
          body: '');
    }

    String methodString = methodToString(request.method);
    List<String> methodList = route['method'];

    if (!methodList.contains(methodString)) {
      return Response(
          status: Status.methodNotAllowed, headers: {}, dataType: '', body: '');
    }

    DartshineController controller = route['controller'];
    Response response = Response(
        status: Status.internalServerError,
        headers: {},
        dataType: 'text/html',
        body: '');

    switch (request.method) {
      case Method.get:
        response = controller.get();
        break;
      case Method.post:
        response = controller.post();
        break;
      case Method.patch:
        response = controller.patch();
        break;
      case Method.put:
        response = controller.put();
        break;
      case Method.delete:
        response = controller.delete();
        break;
      default:
    }

    return response;
  }
}
