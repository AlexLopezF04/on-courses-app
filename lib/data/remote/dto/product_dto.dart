import '../../../domain/model/product.dart';

class ProductDto {
  final int id;
  final String title;
  final String slug;
  final String description;
  final double price;
  final String? coverImage;
  final String categoryName;
  final String professorName;
  final bool isActive;
  final int modulesCount;
  final String createdAt;

  ProductDto({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    this.coverImage,
    required this.categoryName,
    required this.professorName,
    required this.isActive,
    required this.modulesCount,
    required this.createdAt,
  });

  /// Mapea la respuesta JSON de curso del backend Django.
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // Resguarda que el precio sea mapeado a double de forma segura (a veces viene como String)
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      coverImage: json['cover_image'] as String?,
      categoryName: json['category_name'] as String? ?? '',
      professorName: json['professor_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      modulesCount: json['modules_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Convierte el DTO a la entidad de dominio.
  Product toDomain() {
    return Product(
      id: id,
      title: title,
      slug: slug,
      description: description,
      price: price,
      coverImage: coverImage,
      categoryName: categoryName,
      professorName: professorName,
      isActive: isActive,
      modulesCount: modulesCount,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
