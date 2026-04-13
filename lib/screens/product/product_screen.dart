import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snova/screens/product/product_card_screen.dart';
import 'product_controller.dart';
import '../model/product_model.dart';

class ProductScreen extends StatelessWidget {
  final ProductController controller;

  const ProductScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty) {
        return const Center(child: Text("No products found"));
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),

        itemCount: controller.products.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),

        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ProductCardScreen(item: product);
        },
      );
    });
  }
}