import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product_model.dart';

class CartController extends GetxController {
  var cartItems = <ProductModel>[].obs;

  final double shippingFee = 30;
  final double discountPercent = 30;

  void addToCart(ProductModel product) {
    final index = cartItems.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      cartItems[index] =
          cartItems[index].copyWith(quantity: 1, isSelected: true);
    } else {
      cartItems.add(product.copyWith(quantity: 1, isSelected: true));
    }
    cartItems.refresh();
  }

  void removeFromCart(ProductModel product) {
    cartItems.removeWhere((p) => p.id == product.id);
    cartItems.refresh();
  }

  void toggleSelection(ProductModel product) {
    final index = cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      cartItems[index] = cartItems[index]
          .copyWith(isSelected: !cartItems[index].isSelected);
      cartItems.refresh();
    }
  }

  double get subTotal => cartItems
      .where((p) => p.isSelected)
      .fold(0, (sum, item) => sum + item.price * item.quantity);

  double get discountAmount => subTotal * discountPercent / 100;

  double get total =>
      subTotal == 0 ? 0 : subTotal - discountAmount + shippingFee;

  Future<void> saveOrderToFirestore(String userEmail) async {
    try {
      final selectedItems =
      cartItems.where((item) => item.isSelected).toList();

      if (selectedItems.isEmpty) return;

      final orderData = {
        "userEmail": userEmail, // 👈 UNIQUE USER IDENTIFIER
        "items": selectedItems.map((item) => {
          "id": item.id,
          "title": item.title,
          "price": item.price,
          "quantity": item.quantity,
          "thumbnail": item.thumbnail,
        }).toList(),
        "subtotal": subTotal,
        "discount": discountAmount,
        "shipping": shippingFee,
        "total": total,
        "status": "Delivered",
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("orders")
          .add(orderData);

    } catch (e) {
      print("Firestore Error: $e");
      rethrow;
    }
  }
}