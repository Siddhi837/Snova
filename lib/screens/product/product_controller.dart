import 'package:get/get.dart';
import '../api/dio_client.dart';
import '../api/product_api_service.dart';
import '../model/product_model.dart';

class ProductController extends GetxController {
  late ProductApiService _apiService;

  var products = <ProductModel>[].obs;
  var categories = <String>[].obs;

  var isLoading = false.obs;

  String? currentCategory;

  final Map<String, String> categorySlugMap = {};

  @override
  void onInit() {
    super.onInit();
    _apiService = ProductApiService(DioClient.getDio());
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getCategories();

      for (var c in response) {
        print("Slug: ${c.slug}, Name: ${c.name}");
      }

      final futures = response.map((category) async {
        try {
          final name = category.name;
          final slug = category.slug;

          if (name == null || name.isEmpty || slug == null || slug.isEmpty) {
            return null;
          }

          final res = await _apiService.getProductsByCategory(
            slug,
            1,
            0,
          );

          print("CHECK: $name ($slug) -> ${res.products.length}");

          if (res.products.isNotEmpty) {
            return MapEntry(name, slug);
          }

          return null;

        } catch (e) {
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);

      List<String> validCategories = [];

      for (var item in results) {
        if (item != null) {
          validCategories.add(item.key);
          categorySlugMap[item.key] = item.value;
        }
      }

      categories.assignAll(validCategories);

      if (categories.isNotEmpty) {
        currentCategory = categories.first;
        await fetchProducts();
      }

    } catch (e) {
      print("CATEGORY ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchProducts() async {
    try {
      if (currentCategory == null) return;

      isLoading.value = true;

      final slug = categorySlugMap[currentCategory!];

      if (slug == null || slug.isEmpty) {
        return;
      }

      final response = await _apiService.getProductsByCategory(
        slug,
        100,
        0,
      );

      products.assignAll(response.products);

    } catch (e) {
      print("PRODUCT ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    currentCategory = category;
    await fetchProducts();
  }
}