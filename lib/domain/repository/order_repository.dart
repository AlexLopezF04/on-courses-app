import '../model/order.dart';
import '../model/product.dart';

abstract class OrderRepository {
  /// Obtiene el historial de compras/inscripciones del estudiante.
  Future<List<Order>> getMyOrders();

  /// Procesa el carrito de compras y genera una nueva orden. Soporta código de cupón opcional.
  Future<Order> createOrder({String? couponCode});

  /// Obtiene los detalles de una orden/inscripción por su ID.
  Future<Order> getOrderDetail(int orderId);

  // --- Operaciones de Carrito (Gestionado en backend mediante /api/carts/) ---

  /// Obtiene los cursos que están actualmente agregados al carrito de compras.
  Future<List<Product>> getCartItems();

  /// Agrega un curso al carrito de compras.
  Future<void> addToCart(int courseId);

  /// Elimina un curso del carrito de compras.
  Future<void> removeFromCart(int courseId);

  /// Vacía todo el contenido del carrito de compras.
  Future<void> clearCart();
}
