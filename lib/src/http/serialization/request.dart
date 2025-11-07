import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:dartshine/dartshine.dart';
import 'package:es_compression/brotli.dart';
import 'package:es_compression/zstd.dart';
import '../serialization/struct.dart';

/// Used to describe the HTTP request
class HttpRequest {
  /// Method of the request
  final Method method;

  /// URI request path
  final String uri;

  /// HTTP version of the request
  final String httpVersion;

  /// HTTP body of the request
  Uint8List body = Uint8List(0);

  /// If the request is in MIME text format, the body will be here
  String text = "";

  /// If the request is in MIME application/json format, the body will be here
  Object? json;

  /// HTTP request headers
  final Map<String, String> headers;

  /// HTTP request parameters
  Map<String, String> parameters = {};

  /// HTTP request dynamic path values
  Map<String, String> dynamicPathValue = {};

  /// HTTP Client cookies
  Map<String, String> cookies = {};

  HttpRequest(this.method, this.uri, this.httpVersion, this.body, this.headers,
      this.parameters);

  Map<String, String> _parseCookie(String cookies) {
    Map<String, String> parsedCookie = {};
    List<String> splittedCookie = cookies.split(";");

    for (String cookie in splittedCookie) {
      cookie = cookie.trim();
      List<String> cookieKeyValue = cookie.split("=");

      parsedCookie[cookieKeyValue[0]] = cookieKeyValue[1];
    }

    return parsedCookie;
  }

  void parseCookieAndContentType() {
    if (headers.containsKey("Cookie")) {
      cookies = _parseCookie(headers["Cookie"]!);
      headers.remove("Cookie");
    }

    if (!headers.containsKey("Content-Type")) {
      return;
    }

    if (headers["Content-Type"]!.startsWith("text/")) {
      text = utf8.decode(body);
    } else if (headers["Content-Type"] == "application/json") {
      json = jsonDecode(utf8.decode(body));
    }
  }
}

class ParseHttpRequest {
  int parsedSize = 0;
  int contentLength = 0;
  Uint8List request = Uint8List(0);
  BytesBuilder body = BytesBuilder();
  bool done = false;
  bool isHeaderParsed = false;
  HttpRequest? result;
  bool isChunked = false;
  List<String> chunkedMethod = [];
  Response response = Response(status: Status.internalServerError, headers: {});

  void parseHeader() {
    int index = -1;

    for (int i = 0; i < request.length; ++i) {
      if (request[i] == 13 &&
          request[i + 1] == 10 &&
          request[i + 2] == 13 &&
          request[i + 3] == 10) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      response = Response.status(status: Status.badRequest);
      throw Error();
    }

    final String requestString = ascii.decode(request.sublist(0, index + 2));

    request = request.sublist(index + 4);

    Map<String, String> headers = {};
    Map<String, String> parameters = {};

    List<String> requestSplit = requestString.split('\r\n');

    final List<String> methodRequest = requestSplit[0].split(' ');
    List<String> splittedUriParameters = methodRequest[1].split("?");

    final Method method = methodWithString(methodRequest[0]);
    final String uri = splittedUriParameters[0];
    final String httpVersion = methodRequest[2];
    requestSplit.removeAt(0);

    if (splittedUriParameters.length > 1) {
      for (String parameter in splittedUriParameters[1].split("&")) {
        List<String> parameterKeyValue = parameter.split("=");

        parameters[parameterKeyValue[0]] = parameterKeyValue[1];
      }
    }

    for (int i = 0; i < requestSplit.length; i++) {
      String data = requestSplit[i];

      if (data.isEmpty) {
        requestSplit.removeRange(0, i);
        break;
      }

      List<String> dataSplit = data.split(':');
      dataSplit[0] = dataSplit[0].trim();
      dataSplit[1] = dataSplit[1].trim();

      if (headers.containsKey(dataSplit[0])) {
        String value = headers[dataSplit[0]]!;
        value += ", ${dataSplit[1]}";
        headers[dataSplit[0]] = value;
      } else {
        headers[dataSplit[0]] = dataSplit[1];
      }
    }

    if (headers.containsKey("Content-Length")) {
      contentLength = int.tryParse(headers["Content-Length"]!) ?? 0;
    } else if (headers.containsKey("Transfer-Encoding")) {
      chunkedMethod = headers["Transfer-Encoding"]!.split(",");

      for (int i = 0; i < chunkedMethod.length; ++i) {
        chunkedMethod[i] = chunkedMethod[i].trim();

        if (chunkedMethod[i] == "chunked") {
          isChunked = true;
        }
      }
    }

    result = HttpRequest(
        method, uri, httpVersion, Uint8List(0), headers, parameters);
  }

  void parseBodyWithLength() {
    parsedSize += request.length;
    body.add(request);

    if (parsedSize == contentLength) {
      done = true;
      result!.body = body.toBytes();
      result!.parseCookieAndContentType();
    }
  }

  void _parseBodyChunkedCompress() {
    result!.body = body.toBytes();

    for (String compressMethod in chunkedMethod) {
      if (compressMethod == "chunked") {
        break;
      } else if (compressMethod == "gzip") {
        final decoder = GZipDecoder();
        result!.body = decoder.decodeBytes(result!.body);
      } else if (compressMethod == "br") {
        result!.body = Uint8List.fromList(brotli.decode(result!.body));
      } else if (compressMethod == "zstd") {
        result!.body = Uint8List.fromList(zstd.decode(result!.body));
      }
    }

    result!.parseCookieAndContentType();
  }

  void parseBodyChunked() {
    int index = 0;

    while (index < request.length) {
      List<String> chunkedSizeString = [];

      while (request[index] != 13 && request[index + 1] != 10) {
        int char = request[index];
        chunkedSizeString.add(utf8.decode([char]));
        ++index;
      }

      index += 2;

      if (chunkedSizeString.isEmpty) {
        response = Response.status(status: Status.lengthRequired);
        throw Error();
      }

      int chunkedSize = int.parse(chunkedSizeString.join(), radix: 16);

      body.add(request.sublist(index, index + chunkedSize));
      index += chunkedSize + 2;

      if (request.length < index) {
        return;
      }

      if (request[index] == 48 &&
          request[index + 1] == 13 &&
          request[index + 2] == 10 &&
          request[index + 3] == 13 &&
          request[index + 4] == 10) {
        done = true;
        result!.body = body.toBytes();
        _parseBodyChunkedCompress();
        result!.parseCookieAndContentType();
        break;
      }
    }
  }

  void parseRequest() {
    if (!isHeaderParsed) {
      parseHeader();
      isHeaderParsed = true;
    }

    if (request.isEmpty) {
      done = true;
      result!.parseCookieAndContentType();
    }

    if (done) {
      return;
    }

    if (contentLength > 0) {
      parseBodyWithLength();
    } else if (isChunked) {
      parseBodyChunked();
    } else {
      response = Response.status(status: Status.lengthRequired);
      throw Error();
    }
  }
}
