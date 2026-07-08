class Validators {
  /// Valida que el email ingresado tenga un formato correcto.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Valida que la contraseña cumpla los requisitos de seguridad del backend (min 8 caracteres).
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  /// Valida que un campo de texto genérico no esté vacío.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo "$fieldName" es obligatorio';
    }
    return null;
  }
}
