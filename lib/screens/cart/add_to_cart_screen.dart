import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snova/screens/utils/common_popup_dialog.dart';
import 'package:snova/screens/utils/dialog_type.dart';
import '../cart/cart_controller.dart';
import '../model/product_model.dart';
import '../home/home_page_activity.dart';

class AddToCartScreen extends StatelessWidget {
  AddToCartScreen({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("My Cart"), centerTitle: true),
      body: Obx(() {
        final selectedItems = controller.cartItems.where((p) => p.isSelected).toList();

        if (selectedItems.isEmpty) return _emptyCartUI(context);

        return Column(
          children: [
            Expanded(child: _cartList(selectedItems)),
            _summarySection(context),
          ],
        );
      }),
    );
  }

  Widget _emptyCartUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Your cart is empty",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text("Looks like you haven't added anything yet",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePageActivity()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Go to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartList(List<ProductModel> selectedItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: selectedItems.length,
      itemBuilder: (context, index) {
        return _cartItem(selectedItems[index]);
      },
    );
  }

  Widget _cartItem(ProductModel item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: item.isSelected,
              onChanged: (_) => controller.toggleSelection(item),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.thumbnail, height: 60, width: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text("₹${item.price}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            _quantityButton(item),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(ProductModel item) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: item.quantity > 1
                ? () {
              item.quantity--;
              controller.cartItems.refresh();
            }
                : null,
          ),
          Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              item.quantity++;
              controller.cartItems.refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _summarySection(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row("Subtotal", "₹${controller.subTotal.toStringAsFixed(2)}"),
          _row("Discounted Subtotal (30% OFF)",
              "₹${(controller.subTotal - controller.discountAmount).toStringAsFixed(2)}"),
          _row("Shipping Charges", "₹${controller.subTotal == 0 ? 0 : controller.shippingFee}"),
          const Divider(),
          _row("Total", "₹${controller.total.toStringAsFixed(2)}", bold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePageActivity()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Go to Home",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.total == 0 ? null : () {
                    CommonPopupDialog.show(
                      contxt: context,
                      type: DialogType.success,
                      title: "Congratulations!",
                      msg: "You order delivered Successfully",
                      onCompleted: () async {
                        try {
                          String? userEmail = FirebaseAuth.instance.currentUser?.email;
                          await controller.saveOrderToFirestore(userEmail!);
                          controller.cartItems.clear();
                          controller.cartItems.refresh();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HomePageActivity()),
                          );
                        }catch (e) {
                          print("Order Failed: $e");
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Checkout", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _row(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}