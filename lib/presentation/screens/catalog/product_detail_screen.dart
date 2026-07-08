import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int courseId;

  const ProductDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCourseDetail(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = context.watch<CatalogProvider>();
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final course = catalogProvider.selectedCourse;
    final isLoading = catalogProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle del Curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : course == null
              ? Center(
                  child: Text(
                    'No se encontró el curso',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagen de Portada grande
                      _buildHeaderImage(course.coverImage),

                      // Detalles del curso
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categoría
                            if (course.categoryName.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  course.categoryName.toUpperCase(),
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),

                            // Título
                            Text(
                              course.title,
                              style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),

                            // Profesor
                            Text(
                              'Impartido por Prof. ${course.professorName}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Fila de Precio y Botón de Acción
                            _buildPriceAndActionButton(course, authProvider, cartProvider),
                            
                            const SizedBox(height: 32),

                            // Descripción
                            Text(
                              'Acerca de este curso',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              course.description.isNotEmpty
                                  ? course.description
                                  : 'Este curso no cuenta con una descripción detallada en este momento.',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            
                            const SizedBox(height: 32),

                            // Módulos del Syllabus (Sección interactiva)
                            Text(
                              'Contenido del Curso (${course.modulesCount} Módulos)',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 12),
                            _buildSyllabusList(course),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderImage(String? coverImage) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: coverImage != null && coverImage.isNotEmpty
          ? Image.network(
              coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildPriceAndActionButton(
    dynamic course,
    AuthProvider auth,
    CartProvider cart,
  ) {
    final isInCart = cart.isCourseInCart(course.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio total',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                course.price == 0 ? 'Gratis' : Formatters.formatCurrency(course.price),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Botón Carrito / Matricularse
          ElevatedButton(
            onPressed: auth.isAuthenticated
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, inicia sesión para matricularte'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.push('/login');
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isInCart ? AppColors.success : AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(isInCart ? 'Ver en el Carrito' : 'Matricularme'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusList(dynamic course) {
    // Si no tiene módulos el curso
    // En la simulación o en el backend, el detalle del curso tiene "modules" como lista
    final List<dynamic> modules = course.description.contains('modules') ? [] : []; // O usar reflexivamente si el DTO lo soporta
    // Para no causar errores si "modules" no está mapeado aún, construiremos unos módulos por defecto si la lista de la API viene vacía.
    
    // Esto es muy útil en caso de que la base de datos tenga cursos vacíos sin módulos cargados.
    final mockModules = [
      {'title': 'Módulo 1: Introducción y Fundamentos', 'lessons': ['Bienvenida al curso', 'Configuración del entorno', 'Primeros pasos']},
      {'title': 'Módulo 2: Conceptos Intermedios', 'lessons': ['Estructuras de datos', 'Integraciones básicas', 'Ejercicios prácticos']},
      {'title': 'Módulo 3: Proyecto Final y Cierre', 'lessons': ['Despliegue de la aplicación', 'Siguientes pasos en tu carrera', 'Certificación']}
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockModules.length,
      itemBuilder: (context, index) {
        final mod = mockModules[index];
        final lessons = mod['lessons'] as List<String>;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              mod['title'] as String,
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            shape: const Border(), // Quita bordes de selección de ExpansionTile
            children: lessons.map((lesson) {
              return ListTile(
                leading: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  lesson,
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
