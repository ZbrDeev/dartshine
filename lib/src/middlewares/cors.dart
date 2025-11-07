import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';
import 'package:dartshine/src/middlewares/middleware.dart';

/// **DartshineCors** is a middleware provided by Dartshine. It manages CORS for you. You should place the middleware at the end of the middleware array that you defined, as mentioned here: [DartshineMiddleware].
///
/// ## Example
/// ```dart
/// class Middleware extends DartshineMiddleware {
///   @override
///   List<ResponseFunction> get middlewares => [logger, DartshineCors().handleCors];
/// }
/// ```
class DartshineCors {
  String allowOrigin;
  int maxAge;
  bool allowCredentials;
  List<String> allowMethods = [];
  List<String> allowHeaders;
  List<String> exposeHeaders;

  DartshineCors(
      {this.allowOrigin = "http://localhost:8000",
      this.maxAge = 0,
      this.allowCredentials = true,
      List<Method> allowMethods = const [],
      this.allowHeaders = const ["*"],
      this.exposeHeaders = const ["*"]}) {
    for (Method method in allowMethods) {
      if (method == Method.all) {
        this.allowMethods = ["*"];
        break;
      }

      this.allowMethods.add(methodToString(method));
    }
  }

  Future<Response> handleCors(
      HttpRequest request, MiddlewareNextFunction next) async {
    if (request.method == Method.options) {
      Map<String, String> headers = {};

      headers["Access-Control-Allow-Origin"] = allowOrigin;
      headers["Access-Control-Allow-Credentials"] = allowCredentials.toString();

      if (maxAge > 0) {
        headers["Access-Control-Max-Age"] = maxAge.toString();
      }

      headers["Access-Control-Allow-Methods"] = allowMethods.join(", ");
      headers["Access-Control-Allow-Headers"] = allowHeaders.join(", ");
      headers["Access-Control-Expose-Headers"] = exposeHeaders.join(", ");

      return Response(status: Status.noContent, body: '', headers: headers);
    } else if (request.method == Method.get || request.method == Method.post) {
      Response response = await next(request);

      response.headers["Access-Control-Allow-Origin"] = allowOrigin;
      response.headers["Access-Control-Allow-Credentials"] =
          allowCredentials.toString();

      if (maxAge > 0) {
        response.headers["Access-Control-Max-Age"] = maxAge.toString();
      }

      response.headers["Access-Control-Allow-Methods"] =
          allowMethods.join(", ");
      response.headers["Access-Control-Allow-Headers"] =
          allowHeaders.join(", ");
      response.headers["Access-Control-Expose-Headers"] =
          exposeHeaders.join(", ");

      return response;
    }

    return next(request);
  }
}
