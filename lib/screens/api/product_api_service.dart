import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:snova/screens/network/product_response.dart';
import 'package:snova/screens/product/category_model.dart';

part 'product_api_service.g.dart';

@RestApi(baseUrl: "https://dummyjson.com/")
abstract class ProductApiService {
  factory ProductApiService(Dio dio, {String baseUrl}) = _ProductApiService;

  @GET("products")
  Future<ProductResponse> getProducts(
    @Query("limit") int limit,
    @Query("skip") int skip,
  );

  @GET("products/categories")
  Future<List<CategoryModel>> getCategories();

  @GET("products/category/{category}")
  Future<ProductResponse> getProductsByCategory(
    @Path("category") String category,
    @Query("limit") int? limit,
    @Query("skip") int? skip,
  );
}
