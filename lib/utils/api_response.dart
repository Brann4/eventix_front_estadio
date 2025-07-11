class ApiResponse<T> {
  final bool status;
  final T? value;
  final String msg;
  final int? statusCode; // Nuevo campo para código de estado HTTP
  final dynamic rawData; // Para acceso a los datos originales si es necesario

  ApiResponse({
    required this.status,
    this.value,
    this.msg = '',
    this.statusCode,
    this.rawData,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) create, {
    int? statusCode,
    dynamic rawData,
  }) {
    return ApiResponse<T>(
      status: json['status'] ?? false,
      value: json['value'] != null ? create(json['value']) : null,
      msg: json['msg'] ?? json['message'] ?? '',
      statusCode: statusCode,
      rawData: rawData ?? json,
    );
  }

  // Método para crear una respuesta de error fácilmente
  static ApiResponse<T> error<T>({
    String message = 'Error desconocido',
    int? statusCode,
    dynamic rawData,
  }) {
    return ApiResponse<T>(
      status: false,
      msg: message,
      statusCode: statusCode,
      rawData: rawData,
    );
  }

  // Método para crear una respuesta exitosa fácilmente
  static ApiResponse<T> success<T>({
    required T value,
    String message = '',
    int? statusCode,
    dynamic rawData,
  }) {
    return ApiResponse<T>(
      status: true,
      value: value,
      msg: message,
      statusCode: statusCode,
      rawData: rawData,
    );
  }

  // Helper para verificar si la respuesta fue exitosa
  bool get isSuccess => status;

  // Helper para verificar si hay un valor
  bool get hasValue => value != null;
}