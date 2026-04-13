import 'package:dio/dio.dart';

class DioClient {
  static Dio getDio() {
    final dio = Dio();

    dio.options.baseUrl = "https://dummyjson.com/";
    return dio;
  }
}