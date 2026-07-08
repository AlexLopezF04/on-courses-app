import 'package:flutter/material.dart';
import '../../data/repository/order_repository_impl.dart';
import '../../domain/model/order.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/order_repository.dart';

class CartProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepositoryImpl();

  List<Product> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Retorna la suma total del precio de los cursos en el carrito.
  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  bool get isEmpty => _cartItems.isEmpty;

  /// Retorna true si un curso específico ya fue agregado al carrito.
  bool isCourseInCart(int courseId) {
    return _cartItems.any((item) => item.id == courseId);
  }

  /// Sincroniza y descarga el carrito del usuario desde la API.
  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartItems = await _orderRepository.getCartItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añade un curso al carrito en el backend y refresca la lista local.
  Future<bool> addToCart(Product course) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.addToCart(course.id);
      await loadCart(); // Sincroniza
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un curso del carrito y refresca.
  Future<bool> removeFromCart(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.removeFromCart(courseId);
      await loadCart();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Vacía todo el carrito.
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _orderRepository.clearCart();
      _cartItems.clear();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Genera una orden de compra / matrícula (checkout) a partir del carrito.
  Future<Order?> checkout({String? couponCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderRepository.createOrder(couponCode: couponCode);
      _cartItems.clear(); // Limpia localmente ya que Django vacía el carrito al comprar
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
