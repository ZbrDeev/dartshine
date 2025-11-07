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
      await _handleRequest(client);
    }
  }

  Future<void> _handleRequest(Socket client) async {
    ParseHttpRequest request = ParseHttpRequest();

    client.listen((data) async {
      try {
        if (!request.done) {
          request.request = data;
          request.parseRequest();
        }
      } catch (e) {
        client.write(request.response);
        await client.close();
        return;
      }

      if (request.done) {
        if (request.result == null) {
          client.write(
              HttpResponse(status: Status.badRequest, headers: {}).response);
          await client.close();
          return;
        }

        PublicHandler handler = PublicHandler(client, request.result!);
        await onRequest(handler);

        await client.close();
        return;
      }
    });
  }
}
