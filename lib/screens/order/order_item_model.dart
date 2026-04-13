class OrderItemModel {
  int id;
  String title;
  double price;
  int quantity;
  String thumbnail;

  OrderItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.thumbnail,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}