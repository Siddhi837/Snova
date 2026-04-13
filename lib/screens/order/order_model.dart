import 'package:json_annotation/json_annotation.dart';

import 'order_item_model.dart';

@JsonSerializable()
class OrderModel {
  String id;
  List<OrderItemModel> items;
  double total;
  String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      items: (json['items'] as List)
          .map((e) =>  OrderItemModel.fromJson(e))
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}