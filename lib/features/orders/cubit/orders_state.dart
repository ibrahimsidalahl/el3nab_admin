import '../data/models/order_model.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final String? activeStatusFilter;

  OrdersLoaded({
    required this.orders,
    this.activeStatusFilter,
  });

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    String? activeStatusFilter,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
    );
  }
}

class OrdersError extends OrdersState {
  final String message;
  
  OrdersError(this.message);
}

class OrderDetailLoading extends OrdersState {}

class OrderDetailLoaded extends OrdersState {
  final OrderModel order;
  
  OrderDetailLoaded(this.order);
}

class OrderDetailError extends OrdersState {
  final String message;
  
  OrderDetailError(this.message);
}
