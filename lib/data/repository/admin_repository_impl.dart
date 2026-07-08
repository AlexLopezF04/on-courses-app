import 'package:dio/dio.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/category.dart';
import '../../domain/model/order.dart';
import '../../domain/model/product.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/admin_repository.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/category_dto.dart';
import '../remote/dto/order_dto.dart';
import '../remote/dto/product_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio = DioClient().dio;

  // --- Gestión de Categorías ---

  @override
  Future<Category> createCategory(String name, String description) async {
    try {
      final response = await _dio.post(
        '/categories/',
        data: {'name': name, 'description': description},
      );
      return CategoryDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Category> updateCategory(int id, String name, String description) async {
    try {
      final response = await _dio.put(
        '/categories/$id/',
        data: {'name': name, 'description': description},
      );
      return CategoryDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/categories/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- Gestión de Cursos (Products) ---

  @override
  Future<Product> createCourse({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath,
  }) async {
    try {
      // Usamos FormData si se sube una imagen de portada nativa
      final Map<String, dynamic> data = {
        'category': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'slug': slug,
        'is_active': true,
      };

      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        final file = await MultipartFile.fromFile(coverImagePath);
        data['cover_image'] = file;
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        '/courses/',
        data: coverImagePath != null ? formData : data,
      );
      return ProductDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Product> updateCourse({
    required int id,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'category': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'slug': slug,
        'is_active': true,
      };

      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        // Si es una ruta local del explorador, cargamos el archivo
        if (!coverImagePath.startsWith('http')) {
          final file = await MultipartFile.fromFile(coverImagePath);
          data['cover_image'] = file;
        }
      }

      final formData = FormData.fromMap(data);

      // Usamos PUT/PATCH para actualizar el curso
      final response = await _dio.put(
        '/courses/$id/',
        data: (coverImagePath != null && !coverImagePath.startsWith('http')) ? formData : data,
      );
      return ProductDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      await _dio.delete('/courses/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- Monitoreo Administrativo ---

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      // Como el usuario logueado es admin, el backend automáticamente
      // nos retornará todas las órdenes en la consulta normal.
      final response = await _dio.get('/orders/');
      final rawData = response.data;
      final List<dynamic> list;
      if (rawData is Map && rawData.containsKey('results')) {
        list = rawData['results'] as List? ?? [];
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list
          .map((json) => OrderDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      // Solo accesible para usuarios staff/admin
      final response = await _dio.get('/users/');
      final rawData = response.data;
      final List<dynamic> list;
      if (rawData is Map && rawData.containsKey('results')) {
        list = rawData['results'] as List? ?? [];
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
