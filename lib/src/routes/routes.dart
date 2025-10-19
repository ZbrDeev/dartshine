import 'package:dartshine/src/controllers/controllers.dart';
import 'package:dartshine/src/controllers/response.dart';
import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/serialization/status.dart';
import 'package:dartshine/src/http/serialization/struct.dart';

/// **RouteUrl** is used to specify the URL with the URI path, controller, and supported methods.
///
/// ## Example
/// ```dart
/// RouteUrl(
///   path: "/",
///   controller: MyController(),
///   method: [Method.get, Method.post]
/// );
/// ```
class RouteUrl {
  String path;
  final DartshineController controller;
  final List<Method> method;
  Map<String, String> dynamicPathValue = {};

  RouteUrl(
      {required this.path, required this.controller, required this.method});
}

class RouteNode {
  RouteNode? dynamicUrl;
  String? dynamicPath;
  Map<String, RouteNode> nodes = {};
  RouteUrl? route;
}

/// Function for error handling
typedef ErrorHandler = Response Function(HttpRequest request);

/// **DartshineRoute** is a class for managing routes, you should create a class and extend to it. You can add some URLs and include error handling to each status.
///
/// ## Example
/// ```dart
/// import 'package:dartshine/dartshine.dart';
///
/// class Routes extends DartshineRoute {
///   @override
///   Map<Status, ErrorHandler> get errorHandlers => {
///         Status.notFound: (HttpRequest request) {
///           return Response.text(status: Status.notFound, body: "page not found");
///         },
///       };
///
///   @override
///   List<RouteUrl> get urls => [
///         RouteUrl(
///             path: "/",
///             controller: RootController(),
///             method: [Method.get, Method.post])
///       ];
/// }
/// ```
class DartshineRoute {
  final List<RouteUrl> urls = [];
  final RouteNode _routes = RouteNode();

  final Map<Status, ErrorHandler> errorHandlers = {};

  void _prepareSingleRoute(RouteUrl url) {
    if (url.path == "/") {
      _routes.route = url;
      return;
    }

    url.path =
        url.path.startsWith("/") ? url.path.replaceFirst("/", "") : url.path;

    url.path = url.path.endsWith("/")
        ? url.path.substring(0, url.path.length - 1)
        : url.path;

    List<String> splittedPath = url.path.split("/");

    Map<String, RouteNode> root = _routes.nodes;
    RouteNode node = _routes;

    for (int i = 0; i < splittedPath.length - 1; ++i) {
      String path = splittedPath[i];

      if (root.containsKey(path)) {
        node = root[path]!;
        root = root[path]!.nodes;
      } else if (node.dynamicUrl != null) {
        root = node.dynamicUrl!.nodes;
        node = node.dynamicUrl!;
      } else {
        if (splittedPath.last.startsWith("<") &&
            RegExp(r"^<[^>]*>$").hasMatch(splittedPath.last)) {
          node.dynamicUrl = RouteNode();
          node.dynamicUrl!.dynamicPath = path;
          root = node.dynamicUrl!.nodes;
          node = node.dynamicUrl!;
        } else {
          root[path] = RouteNode();
          node = root[path]!;
          root = root[path]!.nodes;
        }
      }
    }

    if (splittedPath.last.startsWith("<") &&
        RegExp(r"^<[^>]*>$").hasMatch(splittedPath.last)) {
      node.dynamicUrl = RouteNode();
      node.dynamicUrl!.dynamicPath = splittedPath.last;
      node.dynamicUrl!.route = url;
    } else {
      node.nodes[splittedPath.last] = RouteNode();
      node = node.nodes[splittedPath.last]!;
      node.route = url;
    }
  }

  void prepareRoutes() {
    for (RouteUrl url in urls) {
      _prepareSingleRoute(url);
    }
  }

  RouteUrl? findUrl(String urlPath) {
    RouteNode node = _routes;

    if (urlPath == "/") {
      return node.route;
    }

    urlPath = urlPath.startsWith("/") ? urlPath.replaceFirst("/", "") : urlPath;
    urlPath = urlPath.endsWith("/")
        ? urlPath.substring(0, urlPath.length - 1)
        : urlPath;

    Map<String, String> dynamicPathValue = {};

    for (String path in urlPath.split("/")) {
      if (node.nodes.containsKey(path)) {
        node = node.nodes[path]!;
      } else if (node.dynamicUrl != null) {
        node = node.dynamicUrl!;

        String dynamicPath =
            node.dynamicPath!.substring(1, node.dynamicPath!.length - 1);
        dynamicPathValue[dynamicPath] = path;
      } else {
        return null;
      }
    }

    node.route!.dynamicPathValue = dynamicPathValue;

    return node.route;
  }
}
