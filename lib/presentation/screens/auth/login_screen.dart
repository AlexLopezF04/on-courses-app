import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Sesión iniciada correctamente!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/catalog');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono Educativo Premium
                  const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OnCourses',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu plataforma de aprendizaje online',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 48),

                  // Campo Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Ingresa tu nombre de usuario',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (val) => Validators.validateRequired(val, 'Usuario'),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),

                  // Botón Iniciar Sesión
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 24),

                  // Enlace de Navegación a Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Regístrate aquí',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
