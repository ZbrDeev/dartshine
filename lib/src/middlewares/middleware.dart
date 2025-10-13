import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';
import 'package:dartshine/src/http/tcp/public_handler.dart';
import 'package:dartshine/src/routes/routes.dart';

import 'dart:io';

import 'package:mime/mime.dart';

typedef MiddlewareNextFunction = Future<Response> Function(HttpRequest request);
typedef ResponseFunction = Future<Response> Function(
    HttpRequest request, MiddlewareNextFunction next);

class DartshineMiddleware {
  final List<ResponseFunction> middlewares = [];
  int _index = 0;

  late DartshineRoute _routes;
  RouteUrl? _routeUrl;

  void handleMiddleware(
      PublicHandler handler, HttpRequest request, DartshineRoute routes) async {
    _routes = routes;

    _findRoutes(request);

    final Response response = await runMiddleware(request);
    handler.send(response.status, response.headers, response.dataType,
        response.body, response.responseCookies);
    _index = 0;
  }

  Future<Response> runMiddleware(HttpRequest request) async {
    if (_index < middlewares.length) {
      var middleware = middlewares[_index];
      _index++;
      return middleware(request, runMiddleware);
    } else {
      return _onRequest(request);
    }
  }

  Future<Response> _onRequest(HttpRequest request) async {
    String uri = request.uri;

    if (request.uri.endsWith("/") && request.uri != "/") {
      return Response(status: Status.movedPermanently, headers: {
        'Location': request.uri.substring(0, request.uri.length - 1)
      });
    } else if (uri.contains(
      RegExp(
        r'\.(html|htm|css|js|json|xml|txt|csv|jpg|jpeg|png|gif|svg|webp|ico|bmp|tiff|tif|mp4|webm|ogg|mov|avi|mkv|mp3|wav|m4a|aac|woff|woff2|ttf|otf|eot|pdf|zip|rar)$',
      ),
    )) {
      if (uri.startsWith('/')) {
        uri = uri.substring(1);
      }

      File file = File(uri);

      if (await file.exists()) {
        Response response = Response(
            status: Status.ok,
            headers: {},
            dataType: lookupMimeType(file.path)!,
            body: await file.readAsBytes());

        return response;
      } else {
        return Response(status: Status.notFound, headers: {}, dataType: '');
      }
    } else {
      Response response = _makeResposne(request);
      return response;
    }
  }

  Response _makeResposne(HttpRequest request) {
    if (_routeUrl == null) {
      if (_routes.errorHandlers.containsKey(Status.notFound)) {
        Response response = _routes.errorHandlers[Status.notFound]!(request);

        return Response(
            status: Status.notFound,
            headers: response.headers,
            dataType: response.dataType,
            body: response.body);
      }

      return Response(status: Status.notFound, headers: {});
    }

    if (!_routeUrl!.method.contains(request.method)) {
      if (_routes.errorHandlers.containsKey(Status.methodNotAllowed)) {
        Response response =
            _routes.errorHandlers[Status.methodNotAllowed]!(request);

        return Response(
            status: Status.methodNotAllowed,
            headers: response.headers,
            dataType: response.dataType,
            body: response.body);
      }

      return Response(status: Status.methodNotAllowed, headers: {});
    }

    Response response =
        Response(status: Status.internalServerError, headers: {});

    switch (request.method) {
      case Method.get:
        response = _routeUrl!.controller.get(request);
        break;
      case Method.post:
        response = _routeUrl!.controller.post(request);
        break;
      case Method.patch:
        response = _routeUrl!.controller.patch(request);
        break;
      case Method.put:
        response = _routeUrl!.controller.put(request);
        break;
      case Method.delete:
        response = _routeUrl!.controller.delete(request);
        break;
      default:
        {
          if (_routes.errorHandlers.containsKey(Status.internalServerError)) {
            Response response =
                _routes.errorHandlers[Status.internalServerError]!(request);

            return Response(
                status: Status.internalServerError,
                headers: response.headers,
                dataType: response.dataType,
                body: response.body);
          }
          return Response(status: Status.internalServerError, headers: {});
        }
    }

    return response;
  }

  void _findRoutes(HttpRequest request) {
    _routeUrl = _routes.findUrl(request.uri);

    if (_routeUrl != null) {
      request.dynamicPathValue = _routeUrl!.dynamicPathValue;
    }
  }
}
