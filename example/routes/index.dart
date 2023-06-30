import 'package:dart_frog/dart_frog.dart';
import 'package:poison/poison.dart';

Future<Response> onRequest(RequestContext context) => methodRequest(
      requestContext: context,
      get: _get,
    );

Response _get(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}
