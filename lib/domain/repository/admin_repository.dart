import '../model/category.dart';
import '../model/product.dart';
import '../model/order.dart';
import '../model/user.dart';

abstract class AdminRepository {
  // --- Gestión Administrativa de Categorías ---
  
  /// Crea una nueva categoría.
  Future<Category> createCategory(String name, String description);

  /// Actualiza una categoría existente.
  Future<Category> updateCategory(int id, String name, String description);

  /// Elimina una categoría.
  Future<void> deleteCategory(int id);

  // --- Gestión Administrativa de Cursos (Products) ---

  /// Crea un nuevo curso en el sistema.
  Future<Product> createCourse({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath, // Ruta al archivo local de imagen (opcional)
  });

  /// Modifica un curso existente.
  Future<Product> updateCourse({
    required int id,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath,
  });

  /// Elimina o desactiva un curso.
  Future<void> deleteCourse(int id);

  // --- Monitoreo Administrativo ---

  /// Obtiene el listado global de todas las órdenes de la plataforma (Solo Admin).
  Future<List<Order>> getAllOrders();

  /// Obtiene la lista global de todos los usuarios registrados (Solo Admin).
  Future<List<User>> getAllUsers();
}
