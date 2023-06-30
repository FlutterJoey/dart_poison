// ignore_for_file: Generated using data class generator
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:poison/poison.dart';

import '../../middleware/exception_handler.dart';

Future<Response> onRequest(RequestContext context) async {
  return methodRequest(requestContext: context, post: _post);
}

Future<Response> _post(RequestContext context) async {
  final user = User.fromMap(await context.validateModel(viewModel: User));
  if (user.password != '123') {
    throw RouteNotFoundException();
  }
  return Response.json(
    body: user.toMap(),
  );
}

class AuthenticationException implements Exception {}

class User {
  User({
    required this.username,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  static String? validateUsername(dynamic value) {
    if (value is! String || value.length < 5) {
      return 'Username is required to be a String of at least 5 characters';
    }
    return null;
  }

  @Serialize(validator: User.validateUsername)
  String username;
  @Serialize()
  String password;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'password': password,
    };
  }

  String toJson() => json.encode(toMap());
}
