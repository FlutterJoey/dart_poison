import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:poison/src/exceptions/bad_request.dart';

Future<void> validateRequest({
  required RequestContext context,
  bool isJson = true,
  Map<String, ValueValidator>? body,
  Map<String, ValueValidator>? headers,
  Map<String, ValueValidator>? parameters,
}) async {
  await validateRequestBody(context, body, isJson: isJson);
  validateHeaders(context, headers);
  validateParams(context, parameters);
}

void validateParams(
  RequestContext context,
  Map<String, ValueValidator>? paramValidator,
) {
  if (paramValidator == null) {
    return;
  }

  paramValidator.validate(context.request.uri.queryParameters);
}

void validateHeaders(
  RequestContext context,
  Map<String, ValueValidator>? headerValidator,
) async {
  if (headerValidator == null) {
    return;
  }
  var headers = context.request.headers;

  headerValidator.validate(headers);
}

Future<void> validateRequestBody(
  RequestContext context,
  Map<String, ValueValidator>? bodyValidator, {
  bool isJson = true,
}) async {
  if (bodyValidator == null) {
    return;
  }
  var body = await context.request.body();

  // attempt to validate json body
  if (isJson) {
    _validateJsonBody(body, bodyValidator);
  } else {
    // attempt to validate formdata body
    await _validateFormData(context, bodyValidator);
  }
}

Future<void> _validateFormData(
  RequestContext context,
  Map<String, ValueValidator> bodyValidator,
) async {
  try {
    var formData = await context.request.formData();
    bodyValidator.validate(formData.fields);
  } on StateError {
    // nothing wrong here, it just is not form data
  } on BadRequestException {
    rethrow;
  }
}

void _validateJsonBody(
  String body,
  Map<String, ValueValidator> bodyValidator,
) {
  try {
    var json = jsonDecode(body);
    if (json is Map<String, dynamic>) {
      bodyValidator.validate(json);
    }
    return;
  } on BadRequestException catch (_) {
    rethrow;
  } on FormatException {
    throw BadRequestException(
      body: {'error': 'Invalid json provided with content type'},
    );
  }
}

extension MapValidator on Map<String, ValueValidator> {
  void validate(Map<String, dynamic> toValidate) {
    try {
      var issues = <String, dynamic>{};
      for (var fieldToValidate in keys) {
        var validator = this[fieldToValidate];
        var value = toValidate[fieldToValidate];
        var validatedResult = validator?.validate(value);
        if (validatedResult != null) {
          issues[fieldToValidate] = validatedResult;
        }
      }
      if (issues.isNotEmpty) {
        throw BadRequestException(
          body: issues,
        );
      }
    } on BadRequestException catch (e) {
      var newBody = {
        ...e.body,
        'expected': asJson(),
      };
      throw BadRequestException(body: newBody);
    }
  }
}

extension ValidatorJsonRepresentation on Map<String, ValueValidator> {
  Map<String, dynamic> asJson() {
    return map(
      (key, value) => MapEntry(
        key,
        value.asJson(),
      ),
    );
  }
}

class ValueValidator {
  ValueValidator({
    this.optional = false,
    this.jsonRepresentation,
    required this.validator,
  });

  ValueValidator.map({
    this.optional = false,
    CustomValidator? validator,
    Map<String, ValueValidator> validators = const {},
  }) {
    jsonRepresentation = validators.asJson();
    this.validator = (value) {
      if (value is! Map) {
        return 'This field requires a map';
      }
      if (value.keys.any((element) => element is! String)) {
        return 'The keys of this map are required to be strings';
      }
      try {
        validators.validate(Map<String, dynamic>.from(value));
      } on BadRequestException catch (e) {
        return e.body;
      }
      return validator?.call(value);
    };
  }

  ValueValidator.list({
    this.optional = false,
    CustomValidator? validator,
    ValueValidator? childValidator,
  }) {
    jsonRepresentation = [
      childValidator?.asJson() ?? 'any',
    ];
    this.validator = (value) {
      if (value is! List) {
        return "This field requires a List";
      }
      var error = value
          .map((e) => childValidator?.validate(e))
          .where((element) => element != null)
          .firstOrNull;
      if (error != null) {
        return [error];
      }
      return validator?.call(value);
    };
  }

  ValueValidator.string({
    this.optional = false,
    this.jsonRepresentation = 'String',
    CustomValidator? validator,
  }) {
    this.validator = (value) {
      if (value is! String) {
        return 'This field requires an int';
      }
      return validator?.call(value);
    };
  }

  ValueValidator.double({
    this.optional = false,
    this.jsonRepresentation = 'double',
    CustomValidator? validator,
  }) {
    this.validator = (value) {
      if (value is! num) {
        var parsed = num.tryParse(value);
        if (parsed == null) {
          return 'This value requires a double';
        }
      }
      return validator?.call(value.toDouble());
    };
  }

  ValueValidator.int({
    this.optional = false,
    this.jsonRepresentation = 'int',
    CustomValidator? validator,
  }) {
    this.validator = (value) {
      if (value is! num && value is! double && value is! int) {
        var parsed = num.tryParse(value);
        if (parsed == null) {
          return 'This field requires an Integer';
        }
        if (parsed.roundToDouble() != parsed) {
          return 'This field requires an Integer';
        }
        return validator?.call(value);
      }

      final correctNumber = value as num;

      if (correctNumber.roundToDouble() != correctNumber.toDouble()) {
        return 'This field requires an Integer';
      }
      return validator?.call(value);
    };
  }

  final bool optional;
  late final CustomValidator validator;
  late final dynamic jsonRepresentation;

  dynamic asJson() => jsonRepresentation ?? 'json';

  String? validate(dynamic value) {
    if (value == null) {
      if (optional) {
        return null;
      }
      return 'This field is required!';
    }

    return validator(value);
  }
}

typedef CustomValidator = dynamic Function(dynamic value);
