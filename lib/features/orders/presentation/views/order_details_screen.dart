import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().fetchOrderDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        centerTitle: true,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderDetailError) {
            return _buildErrorWidget(state.message);
          }

          if (state is OrderDetailLoaded) {
            return _buildOrderDetails(state.order);
          }

          // Fallback: Try to get from cache
          final cachedOrder = context.read<OrdersCubit>().getOrderFromCache(widget.orderId);
          if (cachedOrder != null) {
            return _buildOrderDetails(cachedOrder);
          }

          return const Center(child: Text('جاري التحميل...'));
        },
      ),
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersCubit>().fetchOrderDetails(widget.orderId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            _buildHeaderCard(order),
            const SizedBox(height: 16),

            // Status Card
            _buildStatusCard(order),
            const SizedBox(height: 16),

            // Customer Info Card
            if (order.user != null) ...[
              _buildCustomerCard(order),
              const SizedBox(height: 16),
            ],

            // Vendor Info Card
            if (order.vendorName != null) ...[
              _buildVendorCard(order),
              const SizedBox(height: 16),
            ],

            // Driver Info Card
            if (order.assignedDriver != null) ...[
              _buildDriverCard(order),
              const SizedBox(height: 16),
            ],

            // Delivery Address Card
            if (order.address != null && !order.isPickup) ...[
              _buildAddressCard(order),
              const SizedBox(height: 16),
            ],

            // Order Items Card
            _buildItemsCard(order),
            const SizedBox(height: 16),

            // Price Summary Card
            _buildPriceSummaryCard(order),
            const SizedBox(height: 16),

            // Notes Card
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              _buildNotesCard(order),
              const SizedBox(height: 16),
            ],

            // Rejection Reason Card
            if (order.rejectionReason != null && order.rejectionReason!.isNotEmpty) ...[
              _buildRejectionReasonCard(order),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم الطلب',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '#${order.orderNumber ?? order.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'تاريخ الطلب',
                  value: _formatDate(order.createdAt),
                ),
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'الوقت',
                  value: _formatTime(order.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(order.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الطلب',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status.arabicLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: order.isPickup
                    ? Colors.orange.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.isPickup ? Icons.store : Icons.delivery_dining,
                    size: 18,
                    color: order.isPickup ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isPickup ? 'استلام' : 'توصيل',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: order.isPickup ? Colors.orange : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel order) {
    final user = order.user!;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'معلومات العميل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('الاسم', user.name ?? 'غير محدد'),
            const SizedBox(height: 8),
            _buildDetailRow('الهاتف', user.phone),
            if (user.email != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('البريد', user.email!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'معلومات المتجر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                if (order.vendorLogo != null && order.vendorLogo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.vendorLogo!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.vendorName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(OrderModel order) {
    final driver = order.assignedDriver!;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delivery_dining, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'معلومات السائق',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('الاسم', driver.name ?? 'غير محدد'),
            if (driver.phone != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('الهاتف', driver.phone!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    final address = order.address!;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'عنوان التوصيل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (address.label != null)
              _buildDetailRow('التصنيف', address.label!),
            if (address.street != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('الشارع', address.street!),
            ],
            if (address.building != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('المبنى', address.building!),
            ],
            if (address.floor != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('الطابق', address.floor!),
            ],
            if (address.apartment != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('الشقة', address.apartment!),
            ],
            if (address.additionalDirections != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('معلومات إضافية', address.additionalDirections!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 20),
                const SizedBox(width: 8),
                Text(
                  'عناصر الطلب (${order.items.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.itemImage != null && item.itemImage!.isNotEmpty
                ? Image.network(
                    item.itemImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? 'عنصر غير معروف',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} ر.س × ${item.quantity ?? 1}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                // Option value if any
                if (item.optionValue != null && item.optionValue!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'الخيار: ${item.optionValue}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                // Category if any
                if (item.categoryName != null && item.categoryName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'التصنيف: ${item.categoryName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Item Total
          Text(
            '${item.totalPrice.toStringAsFixed(2)} ر.س',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  Widget _buildPriceSummaryCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ملخص الفاتورة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildPriceRow('المجموع الفرعي', order.subtotal),
            const SizedBox(height: 8),
            if (order.discount > 0) ...[
              _buildPriceRow('الخصم', -order.discount, color: Colors.green),
              const SizedBox(height: 8),
            ],
            if (!order.isPickup) ...[
              _buildPriceRow('رسوم التوصيل', order.deliveryFee),
              const SizedBox(height: 8),
            ],
            if (order.appliedCoupon != null && order.appliedCoupon!.code != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'كوبون: ${order.appliedCoupon!.code}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    '-${order.appliedCoupon!.discount?.toStringAsFixed(2) ?? '0.00'} ر.س',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Payment Method
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getPaymentIcon(order.paymentMethod), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _getPaymentLabel(order.paymentMethod),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {Color? color}) {
    final isNegative = value < 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[700],
          ),
        ),
        Text(
          '${isNegative ? '' : ''}${value.toStringAsFixed(2)} ر.س',
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ملاحظات الطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              order.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReasonCard(OrderModel order) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, size: 20, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'سبب الإلغاء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              order.rejectionReason!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<OrdersCubit>().fetchOrderDetails(widget.orderId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.receivedByCustomer:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.cancelledByVendor:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.receivedByCustomer:
        return Icons.verified;
      case OrderStatus.cancelled:
      case OrderStatus.cancelledByVendor:
        return Icons.cancel;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
      case 'credit_card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقداً عند الاستلام';
      case 'card':
      case 'credit_card':
        return 'بطاقة ائتمانية';
      case 'wallet':
        return 'المحفظة';
      default:
        return method;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
