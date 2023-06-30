import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:poison/poison.dart';

extension RequestValidator on RequestContext {
  Future<void> validate({
    bool isJson = true,
    Map<String, ValueValidator>? body,
    Map<String, ValueValidator>? headers,
    Map<String, ValueValidator>? parameters,
  }) =>
      validateRequest(
        context: this,
        body: body,
        headers: headers,
        parameters: parameters,
        isJson: isJson,
      );

  Future<Map<String, dynamic>> validateModel({
    required Type viewModel,
    bool isJson = true,
  }) async {
    await validateRequestBody(
      this,
      Serializer(viewModel: viewModel).getValidator(),
    );

    var body = jsonDecode(await request.body());
    return Map<String, dynamic>.from(body);
  }
}

extension LoadViewmodelFromRequestBody on RequestContext {
  Future<T> loadValidatedObject<T>(
      T Function(Map<String, dynamic>) deserializer) async {
    var validatedBody = await validateModel(viewModel: T);
    return deserializer(validatedBody);
  }
}
