import '../model/category.dart';
import '../model/product.dart';

abstract class CatalogRepository {
  /// Obtiene el listado de todas las categorías de cursos.
  Future<List<Category>> getCategories();

  /// Obtiene los cursos activos, opcionalmente filtrados por categoría y búsqueda.
  Future<List<Product>> getCourses({int? categoryId, String? search});

  /// Obtiene la información detallada de un curso específico por su ID.
  Future<Product> getCourseDetail(int courseId);
}
