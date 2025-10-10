import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';

class DartshineController {
  Response get(HttpRequest request) {
    return Response(
        status: Status.methodNotAllowed, headers: {}, dataType: '', body: "");
  }

  Response post(HttpRequest request) {
    return Response(
        status: Status.methodNotAllowed, headers: {}, dataType: '', body: "");
  }

  Response put(HttpRequest request) {
    return Response(
        status: Status.methodNotAllowed, headers: {}, dataType: '', body: "");
  }

  Response delete(HttpRequest request) {
    return Response(
        status: Status.methodNotAllowed, headers: {}, dataType: '', body: "");
  }

  Response patch(HttpRequest request) {
    return Response(
        status: Status.methodNotAllowed, headers: {}, dataType: '', body: "");
  }
}
