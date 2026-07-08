import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/loading_overlay.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAdminData();
    });
  }

  void _showFormDialog({dynamic course}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: course?.title ?? '');
    final descController = TextEditingController(text: course?.description ?? '');
    final priceController = TextEditingController(text: course?.price?.toString() ?? '');
    final slugController = TextEditingController(text: course?.slug ?? '');
    
    final adminProvider = context.read<AdminProvider>();
    int? selectedCategoryId;

    // Si estamos editando, intenta buscar el ID de la categoría correspondiente
    if (course != null && adminProvider.categories.isNotEmpty) {
      try {
        final match = adminProvider.categories.firstWhere((c) => c.name == course.categoryName);
        selectedCategoryId = match.id;
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        course == null ? 'Nuevo Curso' : 'Editar Curso',
                        style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),

                      // Dropdown de Selección de Categoría
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: adminProvider.categories.map((c) {
                          return DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedCategoryId = val;
                          });
                        },
                        validator: (val) => val == null ? 'Selecciona una categoría' : null,
                      ),
                      const SizedBox(height: 16),

                      // Título del Curso
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (val) => Validators.validateRequired(val, 'Título'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        maxLines: 3,
                        validator: (val) => Validators.validateRequired(val, 'Descripción'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Fila de Precio y Slug
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              decoration: const InputDecoration(labelText: 'Precio (USD)'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Requerido';
                                if (double.tryParse(val) == null) return 'Inválido';
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: slugController,
                              decoration: const InputDecoration(labelText: 'Slug'),
                              validator: (val) => Validators.validateRequired(val, 'Slug'),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Botones Guardar/Cancelar
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          Navigator.pop(context); // Cierra dialog
                          
                          bool success;
                          if (course == null) {
                            success = await adminProvider.createCourse(
                              categoryId: selectedCategoryId!,
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              price: double.parse(priceController.text),
                              slug: slugController.text.trim(),
                            );
                          } else {
                            success = await adminProvider.updateCourse(
                              id: course.id,
                              categoryId: selectedCategoryId!,
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              price: double.parse(priceController.text),
                              slug: slugController.text.trim(),
                            );
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? '¡Operación realizada con éxito!' : 'Ocurrió un error',
                                ),
                                backgroundColor: success ? AppColors.success : AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isLoading = adminProvider.isLoading;

    // Regla de Negocio: Rol
    final isProfessor = authProvider.isProfessor; // Solo ADMIN elimina, PROFESSOR crea/edita

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Panel: Cursos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: Column(
          children: [
            // Tabs superiores rápidos para alternar entre Cursos y Categorías
            _buildAdminNavigationHeader(),

            // Listado de cursos
            Expanded(
              child: adminProvider.courses.isEmpty
                  ? const Center(child: Text('No hay cursos registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.courses.length,
                      itemBuilder: (context, index) {
                        final course = adminProvider.courses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.book_rounded, color: AppColors.primary),
                            ),
                            title: Text(
                              course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${course.categoryName} • ${Formatters.formatCurrency(course.price)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botón Editar (Disponible para Admin y Profesor)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                                  onPressed: () => _showFormDialog(course: course),
                                ),
                                
                                // Botón Eliminar (Desactivado/Ocultado para Profesor según regla de negocio)
                                if (!isProfessor)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                    onPressed: () => _showConfirmDeleteDialog(course.id),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFormDialog(),
          tooltip: 'Agregar Curso',
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildAdminNavigationHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.book_rounded, size: 18),
              label: const Text('Cursos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton.icon(
              onPressed: () => context.go('/admin/categories'),
              icon: const Icon(Icons.category_rounded, size: 18),
              label: const Text('Categorías'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(int courseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este curso? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().deleteCourse(courseId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Curso eliminado correctamente' : 'Error al eliminar',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
