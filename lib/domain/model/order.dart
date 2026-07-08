class OrderItem {
  final int id;
  final int orderId;
  final int courseId;
  final String courseTitle;
  final double price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.courseId,
    required this.courseTitle,
    required this.price,
  });
}

class Order {
  final int id;
  final int userId;
  final String userName;
  final double totalAmount;
  final double discount;
  final double finalAmount;
  final String status; // 'pending' | 'completed' | 'cancelled'
  final String? couponCode;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalAmount,
    required this.discount,
    required this.finalAmount,
    required this.status,
    this.couponCode,
    required this.items,
    required this.createdAt,
  });
}
