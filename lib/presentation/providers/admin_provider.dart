import 'package:flutter/material.dart';
import '../../data/repository/admin_repository_impl.dart';
import '../../data/repository/catalog_repository_impl.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/admin_repository.dart';
import '../../domain/repository/catalog_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepositoryImpl();
  final CatalogRepository _catalogRepository = CatalogRepositoryImpl();

  List<Category> _categories = [];
  List<Product> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Product> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Descarga los listados completos de cursos y categorías para el panel de control.
  Future<void> loadAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _catalogRepository.getCategories();
      _courses = await _catalogRepository.getCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CRUD Categorías ---

  Future<bool> createCategory(String name, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.createCategory(name, description);
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.updateCategory(id, name, description);
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.deleteCategory(id);
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- CRUD Cursos (Products) ---

  Future<bool> createCourse({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.createCourse(
        categoryId: categoryId,
        title: title,
        description: description,
        price: price,
        slug: slug,
        coverImagePath: coverImagePath,
      );
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse({
    required int id,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String slug,
    String? coverImagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.updateCourse(
        id: id,
        categoryId: categoryId,
        title: title,
        description: description,
        price: price,
        slug: slug,
        coverImagePath: coverImagePath,
      );
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.deleteCourse(id);
      await loadAdminData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
