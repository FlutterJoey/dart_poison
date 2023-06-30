// ignore_for_file: Generated using data class generator

import 'package:dart_frog/dart_frog.dart';

import 'package:poison/poison.dart';

Future<Response> onRequest(RequestContext context) async {
  return methodRequest(
    requestContext: context,
    get: list,
    post: create,
  );
}

Future<Response> list(RequestContext context) async {
  return Response.json();
}

Future<Response> create(RequestContext context) async {
  final postModel = CreatePostModel.fromMap(
    await context.validateModel(viewModel: CreatePostModel),
  );

  if (postModel.author != 'joey') {
    throw NotAllowedToCreateException();
  }

  return Response.json(
    statusCode: 201,
    headers: {
      'Location': '/api/posts/1',
    },
  );
}

class NotAllowedToCreateException implements Exception {}

class CreatePostModel {
  CreatePostModel({
    required this.author,
    required this.message,
  });

  factory CreatePostModel.fromMap(Map<String, dynamic> map) {
    return CreatePostModel(
      author: map['author'] as String,
      message: map['message'] as String,
    );
  }
  @Serialize()
  final String author;
  @Serialize()
  final String message;
}
