import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  /// Crea una instancia de ApiException desde un error de Dio.
  factory ApiException.fromDioException(DioException error) {
    String message = 'Ha ocurrido un error inesperado';
    int? statusCode = error.response?.statusCode;
    dynamic details = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Tiempo de espera de conexión agotado';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Tiempo de espera de envío de datos agotado';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de espera de recepción de datos agotado';
        break;
      case DioExceptionType.badResponse:
        // Intenta obtener un mensaje legible del JSON devuelto por Django
        if (details != null) {
          if (details is Map) {
            if (details.containsKey('detail')) {
              message = details['detail'].toString();
            } else if (details.containsKey('error')) {
              message = details['error'].toString();
            } else if (details.containsKey('non_field_errors')) {
              final nfe = details['non_field_errors'];
              message = nfe is List ? nfe.join(", ") : nfe.toString();
            } else {
              // Concatena errores de campos específicos (para formularios)
              final errorBuffer = StringBuffer();
              details.forEach((key, value) {
                final formattedValue = value is List ? value.join(", ") : value.toString();
                errorBuffer.writeln('$key: $formattedValue');
              });
              message = errorBuffer.toString().trim();
            }
          } else {
            message = details.toString();
          }
        } else {
          message = 'Error en el servidor ($statusCode)';
        }
        break;
      case DioExceptionType.cancel:
        message = 'La petición fue cancelada';
        break;
      case DioExceptionType.connectionError:
        message = 'Error de conexión con el servidor. Verifica tu internet';
        break;
      default:
        message = 'Error de red. Asegúrate de tener conexión a internet';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }

  @override
  String toString() => message;
}
