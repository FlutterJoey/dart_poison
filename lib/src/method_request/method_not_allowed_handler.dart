import 'package:dart_frog/dart_frog.dart';
import 'package:poison/poison.dart';

ExceptionHandler<MethodNotAllowedException> methodNotAllowedHandler =
    (context, error) => Response.json(
          body: {
            'message':
                'Method: ${context.request.method.name.toUpperCase()} not allowed',
            'Allowed methods':
                error.allowedMethods.map((e) => e.toUpperCase()).toList(),
          },
        );
