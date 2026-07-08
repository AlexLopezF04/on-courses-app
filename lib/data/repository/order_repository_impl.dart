import 'package:dio/dio.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/order.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/order_repository.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/order_dto.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Order>> getMyOrders() async {
    try {
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
  Future<Order> createOrder({String? couponCode}) async {
    try {
      final Map<String, dynamic> data = {};
      if (couponCode != null && couponCode.isNotEmpty) {
        // El backend tiene un endpoint que recibe { coupon: "CUPON" } o similar
        // De acuerdo con OrderWriteSerializer, el campo es "coupon" (ID o string)
        data['coupon'] = couponCode; 
      }

      final response = await _dio.post('/orders/', data: data);
      return OrderDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Order> getOrderDetail(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/');
      return OrderDto.fromJson(response.data).toDomain();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- Operaciones de Carrito ---

  @override
  Future<List<Product>> getCartItems() async {
    try {
      final response = await _dio.get('/carts/mine/');
      final rawItems = response.data['items'] as List? ?? [];
      
      // Mapeamos los items del carrito a objetos Product parciales
      return rawItems.map((item) {
        final courseId = item['course'] as int;
        final title = item['course_title'] as String? ?? '';
        final price = double.tryParse(item['course_price'].toString()) ?? 0.0;
        
        return Product(
          id: courseId,
          title: title,
          slug: '',
          description: '',
          price: price,
          coverImage: null,
          categoryName: '',
          professorName: '',
          isActive: true,
          modulesCount: 0,
          createdAt: DateTime.now(),
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> addToCart(int courseId) async {
    try {
      await _dio.post(
        '/cart-items/',
        data: {'course': courseId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> removeFromCart(int courseId) async {
    try {
      // 1. Obtener el ID del CartItem correspondiente al courseId
      final response = await _dio.get('/carts/mine/');
      final rawItems = response.data['items'] as List? ?? [];
      
      int? cartItemId;
      for (final item in rawItems) {
        if (item['course'] == courseId) {
          cartItemId = item['id'] as int;
          break;
        }
      }

      // 2. Si encontramos el CartItem, lo eliminamos llamando al DELETE del viewset
      if (cartItemId != null) {
        await _dio.delete('/cart-items/$cartItemId/');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      // El CartViewSet tiene un endpoint para obtener el carrito del usuario.
      // Django permite eliminar sus items. Si no hay endpoint clear, podemos borrar uno por uno.
      final response = await _dio.get('/carts/mine/');
      final rawItems = response.data['items'] as List? ?? [];
      
      for (final item in rawItems) {
        final cartItemId = item['id'] as int;
        await _dio.delete('/cart-items/$cartItemId/');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
