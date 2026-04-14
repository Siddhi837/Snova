import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snova/screens/home/home_page_activity.dart';
import 'package:snova/screens/order/order_controller.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController controller = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePageActivity()),
            );
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return _emptyCartUI();
        }

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListView.builder(
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text("Total: ₹${order.total.toStringAsFixed(2)}"),
                  subtitle: Text("Status: ${order.status}"),
                  children:
                      order.items.map((item) {
                        return ListTile(
                          leading: Image.network(item.thumbnail, width: 50),
                          title: Text(item.title),
                          subtitle: Text("Qty: ${item.quantity}"),
                          trailing: Text("₹${item.price}"),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _emptyCartUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "You haven't ordered yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Looks like you haven't placed any orders yet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Go to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
