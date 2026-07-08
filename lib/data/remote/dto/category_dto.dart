import '../../../domain/model/category.dart';

class CategoryDto {
  final int id;
  final String name;
  final String description;

  CategoryDto({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Mapea la respuesta JSON de categoría del backend Django.
  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  /// Convierte el DTO a formato JSON para enviar al backend (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  /// Convierte el DTO a la entidad de dominio.
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      description: description,
    );
  }
}
