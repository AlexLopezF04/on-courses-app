import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga los datos iniciales al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCatalog();
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<CartProvider>().loadCart();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = context.watch<CatalogProvider>();
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'OnCourses',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
        actions: [
          // Icono del Carrito (Visible si está autenticado)
          if (authProvider.isAuthenticated)
            IconButton(
              icon: Badge.count(
                count: cartProvider.cartItems.length,
                isLabelVisible: cartProvider.cartItems.isNotEmpty,
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => context.push('/cart'),
            ),
          
          const SizedBox(width: 8),

          // Avatar de Perfil o Botón Login
          if (authProvider.isAuthenticated)
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    authProvider.currentUser!.firstName.isNotEmpty
                        ? authProvider.currentUser!.firstName[0].toUpperCase()
                        : authProvider.currentUser!.username[0].toUpperCase(),
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Entrar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.label,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<CatalogProvider>().loadCatalog();
          if (context.read<AuthProvider>().isAuthenticated) {
            await context.read<CartProvider>().loadCart();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de bienvenida premium
            _buildWelcomeBanner(authProvider),

            // Buscador de cursos
            _buildSearchBar(context, catalogProvider),

            // Filtro de Categorías Horizontal
            _buildCategoriesSection(catalogProvider),

            // Listado de Cursos
            Expanded(
              child: _buildCoursesSection(catalogProvider, cartProvider, authProvider),
            ),
          ],
        ),
      ),
      // Botón flotante para acceder al panel de administración (Solo Admin / Profesor)
      floatingActionButton: authProvider.hasWriteAccess
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/admin/products'),
              icon: const Icon(Icons.admin_panel_settings_rounded),
              label: const Text('Admin Panel'),
            )
          : null,
    );
  }

  Widget _buildWelcomeBanner(AuthProvider auth) {
    final name = auth.isAuthenticated ? auth.currentUser!.firstName : 'Invitado';
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $name!',
            style: AppTextStyles.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Qué quieres aprender el día de hoy?',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, CatalogProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar cursos...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
          ),
        ),
        onChanged: (query) {
          provider.searchCourses(query);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoriesSection(CatalogProvider provider) {
    if (provider.categories.isEmpty && provider.isLoading) {
      return const SizedBox(height: 60);
    }

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: provider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Botón de "Todos"
            final isSelected = provider.selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CategoryChip(
                label: 'Todos',
                isSelected: isSelected,
                onTap: () => provider.selectCategory(null),
              ),
            );
          }

          final category = provider.categories[index - 1];
          final isSelected = provider.selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CategoryChip(
              label: category.name,
              isSelected: isSelected,
              onTap: () => provider.selectCategory(category.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesSection(
    CatalogProvider catalog,
    CartProvider cart,
    AuthProvider auth,
  ) {
    if (catalog.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    if (catalog.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'No se pudo conectar al servidor',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                catalog.errorMessage!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => catalog.loadCatalog(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (catalog.courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'No hay cursos disponibles',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: catalog.courses.length,
      itemBuilder: (context, index) {
        final course = catalog.courses[index];
        final isInCart = cart.isCourseInCart(course.id);

        return ProductCard(
          course: course,
          isInCart: isInCart,
          onTap: () => context.push('/courses/${course.id}'),
          onAddToCart: auth.isAuthenticated
              ? () async {
                  if (isInCart) {
                    context.push('/cart');
                  } else {
                    final success = await cart.addToCart(course);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${course.title}" agregado al carrito'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              : () {
                  // Si no está autenticado, lo invitamos a entrar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, inicia sesión para matricularte'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.push('/login');
                },
        );
      },
    );
  }
}
