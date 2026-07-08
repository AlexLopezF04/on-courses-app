import 'package:dio/dio.dart';
import '../../local/secure_storage.dart';
import '../../../core/config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage = SecureStorage();
  Dio? _refreshDio; // Cliente Dio aislado para evitar recursión infinita en peticiones de refresh

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // No inyectar token en rutas públicas de login y registro
    if (options.path.contains('/auth/login/') || options.path.contains('/auth/register/')) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Si el servidor retorna 401 (No Autorizado) y no es el endpoint de login
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/login/')) {
      final refreshToken = await _secureStorage.getRefreshToken();
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Inicializa el cliente de refresco si no existe
          _refreshDio ??= Dio(BaseOptions(baseUrl: AppConfig.apiUrl));
          
          // Llama al endpoint de refresco del backend Django
          final response = await _refreshDio!.post(
            '/auth/refresh/',
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];
            final newRefreshToken = response.data['refresh'];

            // Guarda los nuevos tokens generados
            await _secureStorage.saveAccessToken(newAccessToken);
            if (newRefreshToken != null) {
              await _secureStorage.saveRefreshToken(newRefreshToken);
            }

            // Reintenta la petición original clonando los parámetros con el nuevo token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final cloneDio = Dio(BaseOptions(baseUrl: AppConfig.apiUrl));
            final cloneResponse = await cloneDio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              ),
            );

            // Resuelve la petición original con la respuesta exitosa
            return handler.resolve(cloneResponse);
          }
        } catch (e) {
          // Si el refresh token también expiró o falló la llamada, limpia la sesión
          await _secureStorage.clearSession();
        }
      } else {
        // Si no hay refresh token, limpia la sesión local
        await _secureStorage.clearSession();
      }
    }

    return handler.next(err);
  }
}
