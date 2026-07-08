import 'package:flutter/material.dart';
import '../../data/repository/catalog_repository_impl.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _catalogRepository = CatalogRepositoryImpl();

  List<Category> _categories = [];
  List<Product> _courses = [];
  Product? _selectedCourse;
  int? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Product> get courses => _courses;
  Product? get selectedCourse => _selectedCourse;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga inicial del catálogo (Categorías y Cursos activos).
  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _catalogRepository.getCategories();
      _courses = await _catalogRepository.getCourses(categoryId: _selectedCategoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra cursos por la categoría seleccionada.
  Future<void> selectCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _catalogRepository.getCourses(categoryId: _selectedCategoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene los detalles completos de un curso.
  Future<void> loadCourseDetail(int courseId) async {
    _isLoading = true;
    _selectedCourse = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCourse = await _catalogRepository.getCourseDetail(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
