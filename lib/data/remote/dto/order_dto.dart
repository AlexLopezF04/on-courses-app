import '../../../domain/model/order.dart';

class OrderItemDto {
  final int id;
  final int orderId;
  final int courseId;
  final String courseTitle;
  final double price;

  OrderItemDto({
    required this.id,
    required this.orderId,
    required this.courseId,
    required this.courseTitle,
    required this.price,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: json['id'] as int,
      orderId: json['order'] as int? ?? 0,
      courseId: json['course'] as int? ?? 0,
      courseTitle: json['course_title'] as String? ?? '',
      price: double.tryParse(json['unit_price'].toString()) ?? 0.0,
    );
  }

  OrderItem toDomain() {
    return OrderItem(
      id: id,
      orderId: orderId,
      courseId: courseId,
      courseTitle: courseTitle,
      price: price,
    );
  }
}

class OrderDto {
  final int id;
  final int userId;
  final String userName;
  final double totalAmount;
  final String status;
  final String? couponCode;
  final List<OrderItemDto> items;
  final String createdAt;

  OrderDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalAmount,
    required this.status,
    this.couponCode,
    required this.items,
    required this.createdAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((itemJson) => OrderItemDto.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return OrderDto(
      id: json['id'] as int,
      userId: json['user'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      totalAmount: double.tryParse(json['total'].toString()) ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      couponCode: json['coupon_code'] as String?,
      items: itemsList,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Order toDomain() {
    return Order(
      id: id,
      userId: userId,
      userName: userName,
      // En nuestro modelo del dominio simplificado, totalAmount y finalAmount serán equivalentes al "total" de Django
      totalAmount: totalAmount,
      discount: 0.0, // El backend Django calcula el descuento directo sobre el total
      finalAmount: totalAmount,
      status: status,
      couponCode: couponCode,
      items: items.map((e) => e.toDomain()).toList(),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
