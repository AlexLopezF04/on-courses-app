import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/model/product.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final Product course;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool isInCart;

  const ProductCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onAddToCart,
    this.isInCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada con Gradiente
            AspectRatio(
              aspectRatio: 16 / 9,
              child: course.coverImage != null && course.coverImage!.isNotEmpty
                  ? Image.network(
                      course.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // Cuerpo de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  if (course.categoryName.isNotEmpty)
                    Text(
                      course.categoryName.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accent,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  const SizedBox(height: 6),
                  
                  // Título
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Profesor
                  if (course.professorName.isNotEmpty)
                    Text(
                      'Por ${course.professorName}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  const SizedBox(height: 16),
                  
                  // Fila inferior de precio y carrito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio formateado
                      Text(
                        course.price == 0 ? 'Gratis' : Formatters.formatCurrency(course.price),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Botón interactivo de carrito
                      if (onAddToCart != null)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            onPressed: onAddToCart,
                            style: IconButton.styleFrom(
                              backgroundColor: isInCart ? AppColors.success : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(
                              isInCart
                                  ? Icons.check_rounded
                                  : Icons.add_shopping_cart_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.laptop_chromebook_rounded,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }
}
