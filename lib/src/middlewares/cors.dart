import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';

class DartshineCors {
  String allowOrigin = "*";
  int maxAge = 0;
  bool allowCredentials = true;
  List<Method> allowMethods = [Method.all];
  List<String> allowHeaders = ["*"];
  List<String> exposeHeaders = ["*"];

  Future<Response?> handleCors(HttpRequest request) async {
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
    }

    return null;
  }
}
