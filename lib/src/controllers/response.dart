import 'dart:convert';
import 'package:dartshine/src/http/serialization/response.dart';
import 'package:dartshine/src/http/serialization/status.dart';

/// **Cookie** is a class used by Dartshine for managing cookies. To use it, you should call the constructor in the [Response.setCookie] method.
///
/// ## Example
/// ```dart
/// import 'package:dartshine/dartshine.dart
///
/// Response.setCookie([Cookie(key: "key", value: "value", httpOnly: true, maxAge: 3600)])
/// ```
class Cookie {
  /// The key of the cookie
  final String key;

  /// The value of the cookie
  final String value;

  /// The max age of the cookie, the value should be in timestamp
  int? maxAge;

  /// The path of the cookie
  String path;

  /// If the cookie should be http only
  bool httpOnly;

  /// If the cookie should be sent in a https
  bool secure;

  /// If the cookie should be sent only to this domain name
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

/// **Response** is a class for creating HTTP responses, the class has 5 methods for each type of response, for HTML, JSON, text, status only and redirection.
///
/// ## Example
///
/// ### Create response based on type
/// ```dart
/// import 'package:dartshine/dartshine.dart
/// // You can put some headers with the headers parameter
///
/// // For sending html
/// Response.html(status: Status.ok, body: '<h1>Hello, World</h1>');
///
/// // For sending json
/// Response.json(status: Status.created, data: {"user": {
///   "surname": 'John',
///   "name": 'Doe',
///   "age": 4,
///   "hobbies": ['programming', 'soccer', 'cooking']
/// }});
///
/// // For sending text
/// Response.text(status: Status.notFound, body: "You can't access this page",
///   headers: {"Authorization": "your_token"}
/// );
///
/// // For sending status only
/// Response.status(status: Status.imATeapot);
///
/// // For redirecting
/// Response.redirect('https://www.google.com');
/// ```
///
/// ### Set cookies
/// ```dart
/// Response.status(status: Status.imATeapot).setCookies(
///   [Cookie(key: "key", value: "value", httpOnly: true, maxAge: 3600)]
/// );
/// ```
///
/// ### Set csrf token
/// ```dart
/// Response.status(status: Status.imATeapot).setCsrf(true);
/// ```
class Response {
  late Status status;
  late dynamic body;
  late Map<String, String> headers = {};
  String dataType = '';
  late HttpResponse response;
  List<String> responseCookies = [];
  bool needCsrf = false;

  /// This method is used only if you want to send a file
  Response(
      {required this.status,
      this.body = '',
      required this.headers,
      this.dataType = 'text/html'}) {
    if (dataType.isNotEmpty) {
      headers['Content-Type'] = dataType;
    }
  }

  /// Create a response with an HTML
  Response.html(
      {required this.status,
      required this.body,
      Map<String, String>? headers}) {
    if (headers != null) {
      this.headers = headers;
    }

    dataType = 'text/html';
  }

  /// Create a response with a JSON
  Response.json(
      {required this.status,
      required Object? data,
      Map<String, String>? headers}) {
    if (headers != null) {
      this.headers = headers;
    }

    dataType = 'application/json';
    body = jsonEncode(data);
  }

  /// Create a response with a text
  Response.text(
      {required this.status,
      required this.body,
      Map<String, String>? headers}) {
    if (headers != null) {
      this.headers = headers;
    }

    dataType = 'text/plain';
  }

  /// Create a response with a status only
  Response.status({required this.status, Map<String, String>? headers}) {
    if (headers != null) {
      this.headers = headers;
    }

    body = '';
  }

  /// Create a redirection
  Response.redirect(String url, {Map<String, String>? headers}) {
    status = Status.movedPermanently;

    if (headers != null) {
      this.headers = headers;
    }

    this.headers['Location'] = url;
    body = '';
  }

  /// Add cookies for this response
  Response setCookies(List<Cookie> cookies) {
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

  /// Activate the CSRF token for this response
  Response setCsrf(bool boolean) {
    needCsrf = boolean;

    return this;
  }
}
