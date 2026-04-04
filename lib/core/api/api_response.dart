class ApiResponse<T> {
  final bool    success;
  final T?      data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data:    fromData != null && json['data'] != null
                 ? fromData(json['data'])
                 : json['data'] as T?,
      error:   json['error']?.toString(),
    );
  }

  bool get isSuccess => success && error == null;
}
