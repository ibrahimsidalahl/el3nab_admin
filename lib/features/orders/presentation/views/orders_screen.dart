import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_card.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'الكل', 'status': 'all', 'icon': Icons.list_alt},
    {'label': 'قيد الانتظار', 'status': 'pending', 'icon': Icons.hourglass_empty},
    {'label': 'جاري التحضير', 'status': 'preparing', 'icon': Icons.restaurant},
    {'label': 'في الطريق', 'status': 'out_for_delivery', 'icon': Icons.delivery_dining},
    {'label': 'تم التوصيل', 'status': 'delivered', 'icon': Icons.check_circle},
    {'label': 'ملغي', 'status': 'cancelled', 'icon': Icons.cancel},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Fetch orders on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersCubit>().fetchOrders();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    final status = _tabs[_tabController.index]['status'] as String;
    context.read<OrdersCubit>().filterByStatus(status == 'all' ? null : status);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersCubit>().refreshOrders();
            },
          ),
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrdersError) {
            return _buildErrorWidget(state.message);
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return _buildEmptyWidget();
            }
            return _buildOrdersList(state.orders);
          }

          return const Center(
            child: Text('اسحب للأسفل لتحميل الطلبات'),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final counts = state is OrdersLoaded
            ? context.read<OrdersCubit>().getOrdersCountByStatus()
            : <String, int>{};

        return Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((tab) {
              final count = counts[tab['status']] ?? 0;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab['icon'] as IconData, size: 18),
                    const SizedBox(width: 6),
                    Text(tab['label'] as String),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrdersCubit>().refreshOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
          );
        },
      ),
    );
  }

  void _navigateToOrderDetails(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الطلبات هنا عند وصولها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<OrdersCubit>().refreshOrders();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<OrdersCubit>().refreshOrders();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
