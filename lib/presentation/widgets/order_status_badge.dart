import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String text = 'Pendiente';
    Color color = AppColors.warning;

    switch (status) {
      case 'paid':
        text = 'Inscrito / Pagado';
        color = AppColors.success;
        break;
      case 'cancelled':
        text = 'Cancelado';
        color = AppColors.error;
        break;
      case 'refunded':
        text = 'Reembolsado';
        color = AppColors.info;
        break;
      case 'pending':
      default:
        text = 'Pendiente';
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24), width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
