import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

// Importaciones de pantallas
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_users_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/catalog',
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      // Si el proveedor aún no ha verificado el estado local de la sesión, no redirige
      if (!authProvider.isInitialized) return null;

      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isLoggedIn = authProvider.isAuthenticated;

      // Lista de rutas públicas que no requieren token
      final isPublicRoute = state.matchedLocation == '/catalog' ||
          state.matchedLocation.startsWith('/courses/') ||
          isLoggingIn;

      // 1. Si no está autenticado y la ruta es privada: Redirige al Login
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // 2. Si está autenticado e intenta entrar a Login o Registro: Redirige al Catálogo
      if (isLoggedIn && isLoggingIn) {
        return '/catalog';
      }

      // 3. Ruta de Administración protegida por Rol (Admin / Profesor)
      if (state.matchedLocation.startsWith('/admin')) {
        if (!authProvider.hasWriteAccess) {
          // Si es estudiante, le bloqueamos el paso y redirigimos al Catálogo
          return '/catalog';
        }
      }

      return null;
    },
    routes: [
      // --- Autenticación ---
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // --- Catálogo (Público) ---
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id']!;
          final id = int.tryParse(idStr) ?? 0;
          return ProductDetailScreen(courseId: id);
        },
      ),

      // --- Carrito & Compras (Estudiante) ---
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id']!;
          final id = int.tryParse(idStr) ?? 0;
          return OrderDetailScreen(orderId: id);
        },
      ),

      // --- Administración (Admin o Profesor) ---
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
    ],
  );
}
