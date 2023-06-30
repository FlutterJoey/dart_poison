class BadRequestException implements Exception {
  final Map<String, dynamic> body;

  BadRequestException({
    required this.body,
  });
}
