class Product {
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
  final DateTime createdAt;

  Product({
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
}
