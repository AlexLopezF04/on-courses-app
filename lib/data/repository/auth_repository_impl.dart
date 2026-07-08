import 'package:dio/dio.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/secure_storage.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = DioClient().dio;
  final SecureStorage _secureStorage = SecureStorage();

  @override
  Future<AuthToken> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      final authDto = AuthDto.fromJson(response.data);
      final authToken = authDto.toDomain();

      // Almacena de forma persistente y encriptada los tokens en el dispositivo
      await _secureStorage.saveAccessToken(authToken.accessToken);
      await _secureStorage.saveRefreshToken(authToken.refreshToken);

      return authToken;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<User> getCurrentUser(int userId) async {
    try {
      final response = await _dio.get('/users/$userId/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // Llama al endpoint de invalidación de token del backend
        await _dio.post(
          '/auth/logout/',
          data: {'refresh': refreshToken},
        );
      }
    } on DioException catch (_) {
      // Incluso si la petición HTTP falla en el servidor, 
      // limpiamos los tokens locales para asegurar el logout
    } finally {
      await _secureStorage.clearSession();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
