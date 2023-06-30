import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:poison/poison.dart';

extension MethodRequest on RequestContext {
  FutureOr<Response> method({
    Handler? get,
    Handler? post,
    Handler? patch,
    Handler? put,
    Handler? options,
    Handler? head,
    Handler? delete,
  }) {
    return methodRequest(
      requestContext: this,
      get: get,
      post: post,
      patch: patch,
      put: put,
      options: options,
      head: head,
      delete: delete,
    );
  }
}
