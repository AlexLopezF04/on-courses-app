import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de interactuar con el SDK
  WidgetsFlutterBinding.ensureInitialized();

  // Carga e inicializa variables de entorno de .env
  await AppConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Inicializa el AuthProvider y verifica sesión previa de inmediato
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Recupera la instancia de AuthProvider e inicializa el enrutador
    final authProvider = context.read<AuthProvider>();
    _appRouter = AppRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OnCourses',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
