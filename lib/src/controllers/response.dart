import 'package:dartshine/src/http/serialization/response.dart';
import 'package:dartshine/src/http/serialization/status.dart';

class Cookie {
  final String key;
  final String value;
  int? maxAge;
  String path;
  bool httpOnly;
  bool secure;
  String sameSite;

  Cookie(
      {required this.key,
      required this.value,
      this.maxAge,
      this.path = "/",
      this.httpOnly = false,
      this.secure = false,
      this.sameSite = "none"});
}

class Response {
  final Status status;
  dynamic body;
  final Map<String, String> headers;
  final String dataType;
  late HttpResponse response;
  List<String> responseCookies = [];
  bool needCsrf = false;

  Response(
      {required this.status,
      this.body = '',
      required this.headers,
      this.dataType = 'text/html'}) {
    if (dataType.isNotEmpty) {
      headers['Content-Type'] = dataType;
    }
  }

  Response setCookie(List<Cookie> cookies) {
    for (Cookie cookie in cookies) {
      StringBuffer responseCookie = StringBuffer();
      responseCookie.write("Set-Cookie: ${cookie.key}=${cookie.value}");

      if (cookie.maxAge != null) {
        responseCookie.write("; Max-Age=${cookie.maxAge!.toString()}");
      }

      if (cookie.path != "/") {
        responseCookie.write("; Path=${cookie.path}");
      }

      if (cookie.httpOnly) {
        responseCookie.write("; HttpOnly");
      }

      if (cookie.secure) {
        responseCookie.write("; Secure");
      }

      if (cookie.sameSite != "none") {
        responseCookie.write("; SameSite=${cookie.sameSite}");
      }

      responseCookies.add(responseCookie.toString());
    }

    return this;
  }

  Response addCsrf(bool boolean) {
    needCsrf = boolean;

    return this;
  }
}
