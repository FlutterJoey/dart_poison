import 'dart:async';

import 'package:dart_frog/dart_frog.dart';

class ExceptionHandlerMiddleware {
  List<Middleware> middlewares = [];

  /// Converts the registered [ExceptionHandler]s to a useable middleware 
  /// within dart frog.
  /// 
  /// Due to the nature some other middleware works, you need to have this as
  /// the first middleware. 
  /// 
  /// For example:
  /// ```dart
  /// // don't
  /// handler
  ///   .use(requestLogger())
  ///   .use(handlerMiddleware.asMiddleware())
  /// 
  /// // do
  /// handler
  ///   .use(handlerMiddleware.asMiddlerware())
  ///   .use(requestLogger())
  /// ```
  ///  
  Middleware asMiddleware() {
    return (Handler handler) {
      return middlewares.fold(
        handler,
        (handler, element) => handler.use(element),
      );
    };
  }

  /// Adds an exception handler that will convert an exception of [T] thrown 
  /// somewhere within the aplication to an appropriate response.
  void addExceptionHandler<T>(ExceptionHandler<T> exceptionHandler) {
    middlewares.add(_exceptionHandler<T>(exceptionHandler));
  }
}

Middleware _exceptionHandler<T>(
  ExceptionHandler<T> onException,
) {
  print('creating handler for $T');
  assert(null is! T, 'You cannot use nullable types for handling exceptions');
  return (Handler handler) {
    return (RequestContext requestContext) async {
      try {
        return await handler(requestContext);
        // we ignore this because we guarantee that T is not null, except the
        // linter does not realize this at this point.
        // ignore: nullable_type_in_catch_clause
      } on T catch (error) {
        return onException(requestContext, error);
      } catch (_) {
        rethrow;
      }
    };
  };
}

typedef ExceptionHandler<T> = FutureOr<Response> Function(
  RequestContext context,
  T error,
);
