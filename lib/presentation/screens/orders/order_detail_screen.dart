import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.selectedOrder;
    final isLoading = orderProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detalle de Inscripción #${widget.orderId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/orders'),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : order == null
              ? Center(
                  child: Text(
                    'No se encontró la inscripción',
                    style: AppTextStyles.subtitle,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado de Factura / Inscripción
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Comprobante Digital',
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  OrderStatusBadge(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              Text(
                                'Estudiante:',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                order.userName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                'Fecha de Compra:',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                Formatters.formatDate(order.createdAt.toIso8601String()),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Detalle de ítems (Cursos comprados)
                      Text(
                        'Cursos Matriculados',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: order.items.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: AppColors.border,
                          ),
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                              ),
                              title: Text(
                                item.courseTitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Text(
                                item.price == 0 ? 'Gratis' : Formatters.formatCurrency(item.price),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resumen de Pagos
                      Text(
                        'Resumen Financiero',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Subtotal
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal', style: AppTextStyles.bodyMedium),
                                  Text(
                                    Formatters.formatCurrency(order.totalAmount),
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Descuento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Descuento ${order.couponCode != null ? "(${order.couponCode})" : ""}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    '-${Formatters.formatCurrency(order.discount)}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Divider(height: 1, color: AppColors.border),
                              ),

                              // Total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Final',
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(order.finalAmount),
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botón para Ir a Aprender
                      ElevatedButton(
                        onPressed: () => context.go('/catalog'),
                        child: const Text('Comenzar a Aprender'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
