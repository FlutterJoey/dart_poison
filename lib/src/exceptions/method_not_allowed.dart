class MethodNotAllowedException implements Exception{
  final List<String> allowedMethods;

  MethodNotAllowedException({
    required this.allowedMethods,
  });
}
