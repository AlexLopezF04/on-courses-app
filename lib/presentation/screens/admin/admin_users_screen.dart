import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Panel: Gestión de Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Gestión de Usuarios de la Plataforma',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Módulo administrativo disponible en la siguiente fase de desarrollo.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Volver al Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
