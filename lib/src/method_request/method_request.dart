import 'package:dart_frog/dart_frog.dart';
import 'package:poison/src/exceptions/method_not_allowed.dart';

Future<Response> methodRequest({
  required RequestContext requestContext,
  Handler? get,
  Handler? post,
  Handler? patch,
  Handler? put,
  Handler? options,
  Handler? head,
  Handler? delete,
}) async {
  Map<HttpMethod, Handler> allowedMethods = {
    if (get != null) HttpMethod.get: get,
    if (post != null) HttpMethod.post: post,
    if (patch != null) HttpMethod.patch: patch,
    if (put != null) HttpMethod.put: put,
    if (delete != null) HttpMethod.delete: delete,
    if (head != null) HttpMethod.head: head,
    if (options != null) HttpMethod.options: options,
  };

  var handler = allowedMethods[requestContext.request.method];

  if (handler == null) {
    throw MethodNotAllowedException(
      allowedMethods: allowedMethods.keys.asNameMap().keys.toList(),
    );
  }

  return await handler(requestContext);
}
