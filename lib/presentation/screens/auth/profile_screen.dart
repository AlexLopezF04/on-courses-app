import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isLoading = authProvider.isLoading;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String getRoleText(String role) {
      switch (role) {
        case 'admin':
          return 'Administrador';
        case 'professor':
          return 'Profesor / Docente';
        case 'student':
        default:
          return 'Estudiante';
      }
    }

    Color getRoleColor(String role) {
      switch (role) {
        case 'admin':
          return AppColors.error;
        case 'professor':
          return AppColors.accent;
        case 'student':
        default:
          return AppColors.success;
      }
    }

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/catalog'),
          ),
          actions: [
            // Botón de Logout
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Cerrar Sesión',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.go('/catalog');
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta principal del Perfil
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Avatar con Inicial
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : user.username[0].toUpperCase(),
                          style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Badge de Rol con bordes redondeados
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: getRoleColor(user.role).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getRoleText(user.role).toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: getRoleColor(user.role),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Detalles de la Cuenta
              Text(
                'Detalles de la Cuenta',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                        title: const Text('Correo electrónico'),
                        subtitle: Text(user.email),
                      ),
                      const Divider(height: 1, indent: 56, color: AppColors.border),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                        title: const Text('Teléfono'),
                        subtitle: Text(user.phone ?? 'No registrado'),
                      ),
                      if (user.biography != null && user.biography!.isNotEmpty) ...[
                        const Divider(height: 1, indent: 56, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                          title: const Text('Biografía'),
                          subtitle: Text(user.biography!),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Opciones y Navegación
              Text(
                'Opciones',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bookmark_added_outlined, color: AppColors.primary),
                        title: const Text('Mis Compras / Cursos'),
                        subtitle: const Text('Ver tus cursos matriculados'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/orders'),
                      ),
                      
                      // Entrada al Panel de Administración (Solo Admin / Profesor)
                      if (authProvider.hasWriteAccess) ...[
                        const Divider(height: 1, indent: 56, color: AppColors.border),
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.accent),
                          title: const Text('Panel de Administración'),
                          subtitle: const Text('Gestionar categorías y cursos de la app'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/admin/products'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
