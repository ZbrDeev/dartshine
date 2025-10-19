import 'dart:io';
import 'package:dartshine/dartshine.dart';
import 'package:dartshine/src/http/serialization/response.dart';
import '../serialization/request.dart';
import '../tcp/public_handler.dart';

class ServerMaker {
  final int port;
  late ServerSocket server;
  late Future<void> Function(PublicHandler handler) onRequest;

  ServerMaker(this.port);

  void addOnRequest(Future<void> Function(PublicHandler handler) onRequest) {
    this.onRequest = onRequest;
  }

  void run() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    await for (Socket client in server) {
      client.listen((data) async {
        HttpRequest? request = convert(data);

        if (request == null) {
          client.write(
              HttpResponse(status: Status.badRequest, headers: {}).response);
          client.close();
          return;
        }

        PublicHandler handler = PublicHandler(client, request);
        await onRequest(handler);
      });
    }
  }
}
