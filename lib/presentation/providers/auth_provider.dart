import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../data/local/secure_storage.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepositoryImpl();
  final SecureStorage _secureStorage = SecureStorage();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Retorna si el usuario está autenticado.
  bool get isAuthenticated => _currentUser != null;

  /// Retorna si el usuario autenticado tiene rol de Administrador.
  bool get isAdmin => _currentUser?.role == 'admin';

  /// Retorna si el usuario autenticado tiene rol de Profesor/Docente.
  bool get isProfessor => _currentUser?.role == 'professor';

  /// Retorna si el usuario autenticado tiene privilegios de edición (Admin o Profesor).
  bool get hasWriteAccess => isAdmin || isProfessor;

  /// Verifica el estado de autenticación al abrir la app.
  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await _authRepository.isAuthenticated();
      if (hasToken) {
        final accessToken = await _secureStorage.getAccessToken();
        if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
          final decoded = JwtDecoder.decode(accessToken);
          final userId = decoded['user_id'] as int;
          
          // Recupera el usuario completo de la base de datos
          _currentUser = await _authRepository.getCurrentUser(userId);
        } else {
          // Token expirado localmente
          await _secureStorage.clearSession();
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
      await _secureStorage.clearSession();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Inicia sesión con credenciales
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authRepository.login(username, password);
      final decoded = JwtDecoder.decode(token.accessToken);
      final userId = decoded['user_id'] as int;
      
      // Obtiene los datos del perfil actual
      _currentUser = await _authRepository.getCurrentUser(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = null;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo estudiante
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignora errores y fuerza logout
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia los mensajes de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
