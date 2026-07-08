import 'package:flutter/material.dart';
import '../../data/repository/order_repository_impl.dart';
import '../../domain/model/order.dart';
import '../../domain/repository/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepositoryImpl();

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Descarga el historial de órdenes/inscripciones del usuario autenticado.
  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getMyOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Descarga los detalles de una orden específica.
  Future<void> loadOrderDetail(int orderId) async {
    _isLoading = true;
    _selectedOrder = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderRepository.getOrderDetail(orderId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
