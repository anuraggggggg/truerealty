enum ApiExceptionType {
  timeout,
  noInternet,
  unauthorized,
  forbidden,
  notFound,
  server,
  badResponse,
  unexpected,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.body,
  });

  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final Object? body;

  @override
  String toString() => message;
}
