import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/order_model.dart';
import '../data/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _ordersRepository;
  
  // Cache for orders
  List<OrderModel> _cachedOrders = [];
  String? _currentStatusFilter;

  OrdersCubit({OrdersRepository? ordersRepository})
      : _ordersRepository = ordersRepository ?? OrdersRepository(),
        super(OrdersInitial());

  /// Get cached orders
  List<OrderModel> get cachedOrders => _cachedOrders;

  /// Get orders filtered by current status
  List<OrderModel> get filteredOrders {
    if (_currentStatusFilter == null || _currentStatusFilter == 'all') {
      return _cachedOrders;
    }
    return _cachedOrders.where((order) => order.status.value == _currentStatusFilter).toList();
  }

  /// Fetch all orders from the server
  Future<void> fetchOrders({List<String>? statusFilter}) async {
    try {
      emit(OrdersLoading());
      log('📦 OrdersCubit: Fetching orders...');

      final orders = await _ordersRepository.getAllOrders(statusFilter: statusFilter);
      
      // Sort orders by creation date (newest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _cachedOrders = orders;
      _currentStatusFilter = statusFilter?.isNotEmpty == true ? statusFilter!.first : null;

      log('📦 OrdersCubit: Loaded ${orders.length} orders');
      emit(OrdersLoaded(
        orders: orders,
        activeStatusFilter: _currentStatusFilter,
      ));
    } catch (e) {
      log('❌ OrdersCubit: Error fetching orders: $e');
      emit(OrdersError(e.toString()));
    }
  }

  /// Filter orders by status locally
  void filterByStatus(String? status) {
    if (_cachedOrders.isEmpty) {
      emit(OrdersLoaded(orders: [], activeStatusFilter: status));
      return;
    }

    _currentStatusFilter = status;

    List<OrderModel> filtered;
    if (status == null || status == 'all') {
      filtered = _cachedOrders;
    } else {
      filtered = _cachedOrders.where((order) => order.status.value == status).toList();
    }

    log('📦 OrdersCubit: Filtered to ${filtered.length} orders with status: $status');
    emit(OrdersLoaded(
      orders: filtered,
      activeStatusFilter: status,
    ));
  }

  /// Fetch order details by ID
  Future<void> fetchOrderDetails(String orderId) async {
    try {
      emit(OrderDetailLoading());
      log('📦 OrdersCubit: Fetching order details for: $orderId');

      final order = await _ordersRepository.getOrderById(orderId);
      
      log('📦 OrdersCubit: Loaded order #${order.orderNumber}');
      emit(OrderDetailLoaded(order));
    } catch (e) {
      log('❌ OrdersCubit: Error fetching order details: $e');
      emit(OrderDetailError(e.toString()));
    }
  }

  /// Refresh orders - convenience method
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  /// Get order by ID from cache
  OrderModel? getOrderFromCache(String orderId) {
    try {
      return _cachedOrders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Get orders count by status
  Map<String, int> getOrdersCountByStatus() {
    final counts = <String, int>{
      'all': _cachedOrders.length,
      'pending': 0,
      'preparing': 0,
      'out_for_delivery': 0,
      'delivered': 0,
      'completed': 0,
      'received_by_customer': 0,
      'cancelled': 0,
      'canceled_by_vendor': 0,
    };

    for (final order in _cachedOrders) {
      final statusKey = order.status.value;
      if (counts.containsKey(statusKey)) {
        counts[statusKey] = counts[statusKey]! + 1;
      }
    }

    return counts;
  }
}
