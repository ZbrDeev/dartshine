import 'dart:io';
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
        HttpRequest request = convert(data);

        PublicHandler handler = PublicHandler(client, request);
        await onRequest(handler);
      });
    }
  }
}
