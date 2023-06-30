import 'package:dart_frog/dart_frog.dart';
import 'package:poison/poison.dart';

import '../routes/api/login.dart';
import '../routes/api/posts/index.dart';

ExceptionHandlerMiddleware exceptionHandler = ExceptionHandlerMiddleware()
  ..addExceptionHandler<RouteNotFoundException>(
    (context, error) => Response(statusCode: 404),
  )
  ..addExceptionHandler<BadRequestException>(
    (context, error) => Response.json(statusCode: 400, body: error.body),
  )
  ..addExceptionHandler<HttpStatusException>(
    (context, error) => Response.json(
      statusCode: error.status,
      body: error.errorData,
    ),
  )
  ..addExceptionHandler<AuthenticationException>(
    (context, error) => Response.json(
      statusCode: 401,
      body: {
        'message': 'Wrong credentials provided',
      },
    ),
  )
  ..addExceptionHandler<NotAllowedToCreateException>(
    (context, error) => Response.json(
      statusCode: 403,
      body: {
        'message': 'Not allowed to create a post if the author is not Joey',
      },
    ),
  )
  ..addExceptionHandler(methodNotAllowedHandler);

class RouteNotFoundException implements Exception {}

class HttpStatusException implements Exception {
  const HttpStatusException({
    required this.status,
    this.errorData = const {},
  });

  final Map<String, dynamic> errorData;
  final int status;
}
