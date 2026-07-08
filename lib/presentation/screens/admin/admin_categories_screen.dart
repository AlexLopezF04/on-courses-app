import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/loading_overlay.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAdminData();
    });
  }

  void _showFormDialog({dynamic category}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    final adminProvider = context.read<AdminProvider>();

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
                    category == null ? 'Nueva Categoría' : 'Editar Categoría',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre de Categoría'),
                    validator: (val) => Validators.validateRequired(val, 'Nombre de Categoría'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                    validator: (val) => Validators.validateRequired(val, 'Descripción'),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),

                  // Botones Guardar/Cancelar
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      Navigator.pop(context);
                      
                      bool success;
                      if (category == null) {
                        success = await adminProvider.createCategory(
                          nameController.text.trim(),
                          descController.text.trim(),
                        );
                      } else {
                        success = await adminProvider.updateCategory(
                          category.id,
                          nameController.text.trim(),
                          descController.text.trim(),
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
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isLoading = adminProvider.isLoading;

    // Regla de negocio de eliminación
    final isProfessor = authProvider.isProfessor;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Panel: Categorías'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: Column(
          children: [
            // Tabs superiores
            _buildAdminNavigationHeader(),

            // Listado de Categorías
            Expanded(
              child: adminProvider.categories.isEmpty
                  ? const Center(child: Text('No hay categorías registradas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.categories.length,
                      itemBuilder: (context, index) {
                        final cat = adminProvider.categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.category_rounded, color: AppColors.accent),
                            ),
                            title: Text(
                              cat.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              cat.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Editar
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                                  onPressed: () => _showFormDialog(category: cat),
                                ),
                                
                                // Eliminar (Solo Admin)
                                if (!isProfessor)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                    onPressed: () => _showConfirmDeleteDialog(cat.id),
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
          tooltip: 'Agregar Categoría',
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
            child: TextButton.icon(
              onPressed: () => context.go('/admin/products'),
              icon: const Icon(Icons.book_rounded, size: 18),
              label: const Text('Cursos'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.category_rounded, size: 18),
              label: const Text('Categorías'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(int categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta categoría? Esto podría afectar a los cursos relacionados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().deleteCategory(categoryId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Categoría eliminada correctamente' : 'Error al eliminar',
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
