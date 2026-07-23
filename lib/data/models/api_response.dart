class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.message,
    this.headers = const {},
  });

  final int statusCode;
  final T data;
  final String? message;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  ApiResponse<R> copyWithData<R>(R newData) {
    return ApiResponse<R>(
      statusCode: statusCode,
      data: newData,
      message: message,
      headers: headers,
    );
  }
}
