import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

class LocalSeverIo {
  HttpServer? _server;

  Future<int> start(String path) async {
    debugPrint(path);
    final handler = createStaticHandler(path, defaultDocument: 'index.html', serveFilesOutsidePath: true);

    final pipelineHandler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_securityHeaders())
        .addHandler(handler);

    _server = await shelf_io.serve(pipelineHandler, '127.0.0.1', 8080);
    debugPrint('Server running on http://${_server!.address.host}:${_server!.port}');

    return _server!.port;
  }

  void stop() => _server?.close();

  Middleware _securityHeaders() {
    return (innerHandler) {
      return (request) async {
        final response = await innerHandler(request);
        return response.change(
          headers: {'X-Content-Type-Options': 'nosniff', 'X-Frame-Options': 'DENY', 'Cache-Control': 'no-store'},
        );
      };
    };
  }
}
