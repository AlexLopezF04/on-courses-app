import 'package:dio/dio.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/category_dto.dart';
import '../remote/dto/product_dto.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories/');
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
          .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Product>> getCourses({int? categoryId, String? search}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/courses/',
        queryParameters: queryParams,
      );
      
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
          .map((json) => ProductDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Product> getCourseDetail(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId/');
      return ProductDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
