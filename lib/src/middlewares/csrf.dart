import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/parse_form.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';
import 'package:dartshine/src/middlewares/middleware.dart';
import 'package:uuid/uuid.dart';

class DartshineCsrf {
  static String key = "sessionId";
  static String csrfTokenKeyName = "csrf_token";
  static int maxAge = 60 * 60 * 24 * 7 * 2;
  static String path = "/";
  static bool httpOnly = true;
  static String sameSite = "Lax";
  final String secretKey;

  DartshineCsrf({required this.secretKey});

  Future<Response?> _controleCsrf(
      HttpRequest request, String sessionId, String csrfSessionKey) async {
    if (!request.headers.containsKey("Content-Type") &&
        (request.headers["Content-Type"] !=
                "application/x-www-form-urlencoded" ||
            !request.headers["Content-Type"]!
                .contains("multipart/form-data"))) {
      return Response.text(
          status: Status.forbidden, body: 'Invalid Content-Type');
    }

    Map<String, String> parsedForm = {};

    if (request.body.isNotEmpty) {
      if (request.headers["Content-Type"]!.contains("multipart/form-data")) {
        FormData formData = FormData(
            contentType: request.headers["Content-Type"]!, form: request.body);

        formData.parseFormFormData();

        if (formData.error) {
          return Response.status(status: Status.badRequest);
        }

        parsedForm = formData.fields;
      } else {
        parsedForm = parseFormUrlEncoding(utf8.decode(request.body));
      }
    }

    if (!parsedForm.containsKey(csrfTokenKeyName)) {
      return Response.text(
          status: Status.forbidden, body: 'Missing CSRF Token');
    }

    final hmac = Hmac.sha256();

    final List<int> bytes = [
      ...sessionId.codeUnits,
      ...parsedForm[csrfTokenKeyName]!.codeUnits
    ];

    final mac = await hmac.calculateMac(bytes,
        secretKey: SecretKey(secretKey.codeUnits));

    final result = mac.bytes;

    if (base64.encode(result) != csrfSessionKey) {
      return Response.text(
          status: Status.forbidden, body: 'Invalid sessionId or Csrf key');
    }

    return null;
  }

  Future<Response> handleCsrf(
      HttpRequest request, MiddlewareNextFunction next) async {
    List<String> splitedCookies =
        request.headers["Cookie"]!.replaceAll(RegExp(" "), "").split(";");

    String sessionId = "";
    String csrfSessionKey = "";

    for (String cookie in splitedCookies) {
      int idx = cookie.indexOf("=");
      List<String> cookieTemp = [
        cookie.substring(0, idx).trim(),
        cookie.substring(idx + 1).trim()
      ];

      if (cookieTemp[0] == key) {
        sessionId = cookieTemp[1];
      } else if (cookieTemp[0] == "csrfKey") {
        csrfSessionKey = cookieTemp[1];
      }
    }

    if (request.method == Method.post ||
        request.method == Method.put ||
        request.method == Method.patch ||
        request.method == Method.delete) {
      if (sessionId.isEmpty || csrfSessionKey.isEmpty) {
        return Response.text(
            status: Status.forbidden, body: 'Invalid sessionId or Csrf key');
      }

      Response? controleResponse =
          await _controleCsrf(request, sessionId, csrfSessionKey);

      if (controleResponse != null) {
        return controleResponse;
      }
    }

    Response response = await next(request);
    String sessionIdUuid = "";

    if (sessionId.isEmpty) {
      sessionIdUuid = Uuid().v4();

      response.responseCookies.add(
          "Set-Cookie: $key=$sessionIdUuid; Max-Age=${maxAge.toString()}; Path=$path; HttpOnly; SameSite=$sameSite");
    } else {
      sessionIdUuid = sessionId;
    }

    if (response.needCsrf) {
      String csrfToken = Uuid().v4();

      response.body = (response.body as String).replaceAll('<% csrf_token %>',
          '<input type="hidden" name="csrf_token" value="$csrfToken">');

      final hmac = Hmac.sha256();

      final List<int> bytes = [
        ...sessionIdUuid.codeUnits,
        ...csrfToken.codeUnits
      ];

      final hmacResult = await hmac.calculateMac(bytes,
          secretKey: SecretKey(secretKey.codeUnits));

      String csrfTokenSessionIdVerif = base64.encode(hmacResult.bytes);

      response.responseCookies.add(
          "Set-Cookie: csrfKey=$csrfTokenSessionIdVerif; Max-Age=${maxAge.toString()}; Path=$path; HttpOnly; SameSite=$sameSite");
    }

    return response;
  }
}
