import 'package:flutter/material.dart';

class AppColors {
  // Primarios y Secundarios
  static const Color primary = Color(0xFF0F172A); // Slate 900 (Azul Oscuro Profundo / Académico)
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFFF59E0B); // Amber 500 (Dorado / Acento)
  static const Color accentLight = Color(0xFFFEF3C7); // Amber 100

  // Semánticos
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Neutros
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (Fondo Claro Premium)
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (Texto Principal)
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 (Texto Secundario)
  static const Color textLight = Color(0xFF94A3B8); // Slate 400 (Texto Deshabilitado/Pistas)
  static const Color border = Color(0xFFE2E8F0); // Slate 200 (Bordes y Separadores)

  // Gradientes Premium
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
