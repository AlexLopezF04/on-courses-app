class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'student' | 'professor' | 'admin'
  final String? phone;
  final bool isActive;
  final String? biography;
  final String? country;
  final String? birthDate;
  final String? avatar;
  final String? professionalTitle;
  final String? specialty;
  final String? linkedinUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    required this.isActive,
    this.biography,
    this.country,
    this.birthDate,
    this.avatar,
    this.professionalTitle,
    this.specialty,
    this.linkedinUrl,
  });

  /// Mapea la respuesta de usuario del backend
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      biography: json['biography'] as String?,
      country: json['country'] as String?,
      birthDate: json['birth_date'] as String?,
      avatar: json['avatar'] as String?,
      professionalTitle: json['professional_title'] as String?,
      specialty: json['specialty'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
    );
  }

  /// Convierte el usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone': phone,
      'is_active': isActive,
      'biography': biography,
      'country': country,
      'birth_date': birthDate,
      'avatar': avatar,
      'professional_title': professionalTitle,
      'specialty': specialty,
      'linkedin_url': linkedinUrl,
    };
  }

  /// Retorna el nombre completo del usuario, o el username si está vacío.
  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }
}
