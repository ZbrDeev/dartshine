import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';

/// **DartshineController** is the main class for managing all methods in a route.
/// To use the DartshineController, you should create a class that extends DartshineController.
/// For each method, you should have an HttpRequest parameter and return a [Response].
///
/// ## Example
/// ```dart
/// import 'package:dartshine/dartshine.dart';
///
/// class MyController extends DartshineController {
///   @override
///   Response get(HttpRequest request) {
///     return Response.text(status: Status.ok, body: "Hello From My Controller!");
///   }
/// }
/// ```
class DartshineController {
  /// The GET Method in HTTP
  Response get(HttpRequest request) {
    return Response.status(status: Status.methodNotAllowed);
  }

  /// The POST Method in HTTP
  Response post(HttpRequest request) {
    return Response.status(status: Status.methodNotAllowed);
  }

  /// The PUT Method in HTTP
  Response put(HttpRequest request) {
    return Response.status(status: Status.methodNotAllowed);
  }

  /// The DELETE Method in HTTP
  Response delete(HttpRequest request) {
    return Response.status(status: Status.methodNotAllowed);
  }

  /// The PATCH Method in HTTP
  Response patch(HttpRequest request) {
    return Response.status(status: Status.methodNotAllowed);
  }
}
