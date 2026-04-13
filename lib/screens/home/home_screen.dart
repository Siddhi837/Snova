import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snova/screens/product/product_controller.dart';
import 'package:snova/screens/product/product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMPItemIndex = 0;

  String? imageBase64;
  String? userName;
  String? userEmail;

  final scrollController = ScrollController();
  final controller = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userEmail)
        .get();

    if (doc.exists) {
      setState(() {
        imageBase64 = doc.data()?["imageBase64"];
        userName =
        "${doc.data()?["firstName"] ?? ""} ${doc.data()?["lastName"] ?? ""}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 16),
              _specialOffer(),
              const SizedBox(height: 20),
              _mostPopular(),
              const SizedBox(height: 10),

              Obx(() {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ProductScreen(
                  controller: controller,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    ImageProvider? imageProvider;
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      imageProvider = MemoryImage(base64Decode(imageBase64!));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: imageProvider,
              child: imageProvider == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Have a nice day !", style: TextStyle(fontSize: 14)),
                Text(
                  userName ?? "",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _specialOffer() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("30%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("Today's Special!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text(
                      "Get discount for every\norder, only valid for today",
                      style: TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              child: Image.asset(
                'assets/special_offer_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _mostPopular() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Products",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedMPItemIndex;
                final categoryName = controller.categories[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMPItemIndex = index;
                    });
                    controller.fetchProductsByCategory(categoryName);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}