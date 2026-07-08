import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../interceptor/auth_interceptor.dart';

class DioClient {
  late final Dio _dio;

  // Instancia única (Singleton)
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  Dio get dio => _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agrega el interceptor de autenticación para inyectar JWT y capturar 401
    _dio.interceptors.add(AuthInterceptor());
    
    // Si estuviéramos en modo debug, podríamos agregar un logger de red
    // _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
