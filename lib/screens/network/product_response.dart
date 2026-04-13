import 'package:json_annotation/json_annotation.dart';
import 'package:snova/screens/model/product_model.dart';
part 'product_response.g.dart';

@JsonSerializable()
class ProductResponse {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);

  List<ProductModel> getItemsByCategory(String category) {
    return products
        .where((ProductModel item) => item.category == category)
        .toList();
  }
}