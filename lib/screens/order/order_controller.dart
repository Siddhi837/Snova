import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snova/screens/order/order_model.dart';

class OrderController extends GetxController {

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    fetchOrders(userEmail!);
  }

  void fetchOrders(String userEmail) {
    isLoading.value = true;

    FirebaseFirestore.instance
        .collection("orders")
        .where("userEmail", isEqualTo: userEmail)
        .snapshots()
        .listen((snapshot) {

      orders.value = snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.data(), doc.id);
      }).toList();

      isLoading.value = false;
    });
  }
}