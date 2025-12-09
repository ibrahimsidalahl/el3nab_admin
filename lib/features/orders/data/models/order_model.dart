class OrderModel {
  final String id;
  final int? orderNumber;
  final String? userId;
  final String? vendorId;
  final String? vendorName;
  final String? vendorLogo;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final AppliedCoupon? appliedCoupon;
  final OrderStatus status;
  final OrderAddress? address;
  final String paymentMethod;
  final bool isPickup;
  final String? notes;
  final String? rejectionReason;
  final OrderUser? user;
  final OrderDriver? assignedDriver;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    this.orderNumber,
    this.userId,
    this.vendorId,
    this.vendorName,
    this.vendorLogo,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    this.appliedCoupon,
    required this.status,
    this.address,
    required this.paymentMethod,
    this.isPickup = false,
    this.notes,
    this.rejectionReason,
    this.user,
    this.assignedDriver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle vendor as either String or Map
    String? vendorId;
    String? vendorName;
    String? vendorLogo;
    
    if (json['vendor'] is String) {
      vendorId = json['vendor'] as String;
    } else if (json['vendor'] is Map<String, dynamic>) {
      final vendor = json['vendor'] as Map<String, dynamic>;
      vendorId = vendor['_id'] as String?;
      vendorName = vendor['name'] as String?;
      vendorLogo = vendor['logoPath'] as String?;
    }
    
    return OrderModel(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as int?,
      userId: json['user'] == null 
          ? null 
          : (json['user'] is String 
              ? json['user'] as String 
              : (json['user'] as Map<String, dynamic>)['_id'] as String),
      vendorId: vendorId,
      vendorName: vendorName,
      vendorLogo: vendorLogo,
      items: (json['items'] as List?)
          ?.where((item) => item != null)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: json['appliedCoupon'] != null && json['appliedCoupon'] is Map
          ? AppliedCoupon.fromJson(json['appliedCoupon'] as Map<String, dynamic>)
          : null,
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      address: json['address'] != null && json['address'] is Map
          ? OrderAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      isPickup: json['isPickup'] as bool? ?? false,
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      user: json['user'] != null && json['user'] is Map
          ? OrderUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      assignedDriver: json['assignedDriver'] != null && json['assignedDriver'] is Map
          ? OrderDriver.fromJson(json['assignedDriver'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'user': userId,
      'vendor': vendorId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'total': total,
      'appliedCoupon': appliedCoupon?.toJson(),
      'status': status.value,
      'address': address?.toJson(),
      'paymentMethod': paymentMethod,
      'isPickup': isPickup,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    int? orderNumber,
    String? userId,
    String? vendorId,
    String? vendorName,
    String? vendorLogo,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? total,
    AppliedCoupon? appliedCoupon,
    OrderStatus? status,
    OrderAddress? address,
    String? paymentMethod,
    bool? isPickup,
    String? notes,
    String? rejectionReason,
    OrderUser? user,
    OrderDriver? assignedDriver,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorLogo: vendorLogo ?? this.vendorLogo,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      status: status ?? this.status,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPickup: isPickup ?? this.isPickup,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      user: user ?? this.user,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String itemId;
  final String? itemName;
  final String? itemImage;
  final String? categoryId;
  final String? categoryName;
  final String? optionId;
  final String? optionValue;
  final int? quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.itemId,
    this.itemName,
    this.itemImage,
    this.categoryId,
    this.categoryName,
    this.optionId,
    this.optionValue,
    this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    String itemId;
    String? itemName;
    String? itemImage;
    String? categoryId;
    String? categoryName;
    
    if (item == null) {
      itemId = 'unknown';
      itemName = 'عنصر محذوف';
      itemImage = null;
      categoryId = null;
      categoryName = null;
    } else if (item is String) {
      itemId = item;
      itemName = null;
      itemImage = null;
      categoryId = null;
      categoryName = null;
    } else if (item is Map<String, dynamic>) {
      itemId = item['_id'] as String? ?? 'unknown';
      itemName = item['name'] as String?;
      itemImage = item['imagePath'] as String?;
      
      final category = item['category'];
      if (category is String) {
        categoryId = category;
        categoryName = null;
      } else if (category is Map<String, dynamic>) {
        categoryId = category['_id'] as String?;
        categoryName = category['name'] as String?;
      }
    } else {
      itemId = 'unknown';
      itemName = null;
      itemImage = null;
      categoryId = null;
      categoryName = null;
    }
    
    return OrderItem(
      itemId: itemId,
      itemName: itemName,
      itemImage: itemImage,
      categoryId: categoryId,
      categoryName: categoryName,
      optionId: json['optionId'] as String?,
      optionValue: json['optionValue'] as String?,
      quantity: json['quantity'] as int?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'optionId': optionId,
      'optionValue': optionValue,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

class OrderAddress {
  final String? id;
  final String? name;
  final String? label;
  final String? street;
  final String? fullAddressText;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? additionalDirections;
  final String? notes;
  final List<double>? coordinates;

  OrderAddress({
    this.id,
    this.name,
    this.label,
    this.street,
    this.fullAddressText,
    this.building,
    this.floor,
    this.apartment,
    this.additionalDirections,
    this.notes,
    this.coordinates,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    if (json['location'] != null && json['location'] is Map) {
      final location = json['location'] as Map<String, dynamic>;
      if (location['coordinates'] != null && location['coordinates'] is List) {
        coords = (location['coordinates'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
    }
    
    return OrderAddress(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      label: json['label'] as String?,
      street: json['street'] as String?,
      fullAddressText: json['fullAddress'] as String?,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      additionalDirections: json['additionalDirections'] as String?,
      notes: json['notes'] as String?,
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'label': label,
      'street': street,
      'fullAddress': fullAddressText,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'additionalDirections': additionalDirections,
      'notes': notes,
      if (coordinates != null)
        'location': {
          'type': 'Point',
          'coordinates': coordinates,
        },
    };
  }

  String get displayName => name ?? label ?? 'عنوان';

  String get fullAddress {
    if (fullAddressText != null && fullAddressText!.isNotEmpty) {
      return fullAddressText!;
    }
    
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (building != null && building!.isNotEmpty) parts.add('مبنى $building');
    if (floor != null && floor!.isNotEmpty) parts.add('طابق $floor');
    if (apartment != null && apartment!.isNotEmpty) parts.add('شقة $apartment');
    if (additionalDirections != null && additionalDirections!.isNotEmpty) {
      parts.add(additionalDirections!);
    }
    return parts.isNotEmpty ? parts.join(' - ') : 'لا يوجد عنوان';
  }
}

class OrderUser {
  final String? id;
  final String? name;
  final String phone;
  final String? email;

  OrderUser({
    this.id,
    this.name,
    required this.phone,
    this.email,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    final phoneValue = json['phone'];
    String phoneStr;
    if (phoneValue is int) {
      phoneStr = phoneValue.toString();
    } else if (phoneValue is String) {
      phoneStr = phoneValue;
    } else {
      phoneStr = '';
    }
    
    return OrderUser(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phone: phoneStr,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

class OrderDriver {
  final String? id;
  final String? name;
  final String? phone;

  OrderDriver({
    this.id,
    this.name,
    this.phone,
  });

  factory OrderDriver.fromJson(Map<String, dynamic> json) {
    final phoneValue = json['phone'];
    String? phoneStr;
    if (phoneValue is int) {
      phoneStr = phoneValue.toString();
    } else if (phoneValue is String) {
      phoneStr = phoneValue;
    }
    
    return OrderDriver(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phone: phoneStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class AppliedCoupon {
  final String? id;
  final String? code;
  final double? discount;
  final String? discountType;

  AppliedCoupon({
    this.id,
    this.code,
    this.discount,
    this.discountType,
  });

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
    return AppliedCoupon(
      id: json['_id'] as String?,
      code: json['code'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discountType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'discount': discount,
      'discountType': discountType,
    };
  }
}

enum OrderStatus {
  pending('pending', 'قيد الانتظار'),
  preparing('preparing', 'جاري التحضير'),
  completed('completed', 'جاهز للاستلام'),
  receivedByCustomer('received_by_customer', 'تم التسليم'),
  outForDelivery('out_for_delivery', 'في الطريق'),
  delivered('delivered', 'تم التوصيل'),
  cancelled('cancelled', 'ملغي'),
  cancelledByVendor('canceled_by_vendor', 'ملغي من المطعم');

  final String value;
  final String arabicLabel;

  const OrderStatus(this.value, this.arabicLabel);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
