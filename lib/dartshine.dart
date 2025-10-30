export 'src/controllers/controllers.dart';
export 'src/controllers/response.dart' show Response, Cookie;
export 'src/orm/orm.dart';
export 'src/orm/types.dart' show OrmTypes;
export 'src/orm/db_type.dart' show DbType;
export 'src/routes/routes.dart' show DartshineRoute, RouteUrl, ErrorHandler;
export 'src/templates/templates.dart';
export 'src/http/serialization/struct.dart' show Method;
export 'src/http/serialization/status.dart' show Status;
export 'src/http/serialization/request.dart' show HttpRequest;
export 'src/middlewares/middleware.dart';
export 'src/middlewares/cors.dart';
export 'src/middlewares/compression.dart';
export 'src/middlewares/csrf.dart';
export 'src/forms/forms.dart';

import 'package:dartshine/src/http/serialization/request.dart';
import 'package:dartshine/src/http/tcp/public_handler.dart';
import 'package:dartshine/src/http/tcp/server.dart';
import 'package:dartshine/src/middlewares/middleware.dart';
import 'package:dartshine/src/orm/orm.dart';
import 'package:dartshine/src/routes/routes.dart';

class Server {
  final int port;
  final DartshineRoute routes;
  final DartshineOrm orms;
  final DartshineMiddleware middleware;
  final bool debug;

  Server({
    this.port = 8000,
    required this.routes,
    required this.orms,
    required this.middleware,
    this.debug = true,
  });

  Future<void> run() async {
    ServerMaker server = ServerMaker(port);
    server.addOnRequest(onRequest);
    await orms.fillOrm();
    routes.prepareRoutes();

    if (debug) {
      print('Server run in port $port');
      print('Link: http://localhost:$port');
      print('to quit the server you must do CTRL + C');
    }

    server.run();
  }

  Future<void> onRequest(PublicHandler handler) async {
    HttpRequest request = handler.request;

    await middleware.handleMiddleware(handler, request, routes);
  }
}
