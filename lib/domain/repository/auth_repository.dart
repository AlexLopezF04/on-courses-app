import '../model/auth_models.dart';
import '../model/user.dart';

abstract class AuthRepository {
  /// Inicia sesión con usuario y contraseña. Retorna los tokens JWT.
  Future<AuthToken> login(String username, String password);

  /// Registra un nuevo usuario estudiante.
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Obtiene los detalles de perfil del usuario por su ID.
  Future<User> getCurrentUser(int userId);

  /// Cierra la sesión activa del usuario.
  Future<void> logout();

  /// Verifica si el usuario tiene una sesión local activa.
  Future<bool> isAuthenticated();
}
