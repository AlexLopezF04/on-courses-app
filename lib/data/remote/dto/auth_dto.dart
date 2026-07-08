import '../../../domain/model/auth_models.dart';

class AuthDto {
  final String accessToken;
  final String refreshToken;

  AuthDto({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Mapea la respuesta JSON por defecto de SimpleJWT (access, refresh).
  factory AuthDto.fromJson(Map<String, dynamic> json) {
    return AuthDto(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }

  /// Convierte el DTO a la entidad del dominio AuthToken.
  AuthToken toDomain() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
