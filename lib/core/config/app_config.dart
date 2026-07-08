import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> initialize() async {
    // Carga el archivo .env desde los assets
    await dotenv.load(fileName: ".env");
  }

  /// URL Base de la API de Django
  static String get apiUrl => dotenv.env['API_URL'] ?? 'https://on-courses-api.uaeftt-ute.site/api';

  /// Timeout de conexión en milisegundos
  static int get connectionTimeout => int.parse(dotenv.env['CONNECTION_TIMEOUT'] ?? '5000');

  /// Timeout de recepción de datos en milisegundos
  static int get receiveTimeout => int.parse(dotenv.env['RECEIVE_TIMEOUT'] ?? '3000');
}
