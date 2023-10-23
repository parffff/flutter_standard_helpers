import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpUtils {
  HttpUtils() {
    _initBaseUrl();
  }

  final BaseOptions _dioOptions = BaseOptions(
      responseType: ResponseType.json,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      validateStatus: (int? statusCode) {
        List<int> successCodes = [200, 201];
        return successCodes.contains(statusCode);
      });

  void _initBaseUrl() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    final String baseUrl =
        dotenv.env['API_URL_${isProduction ? 'PROD' : 'DEV'}']!;

    _dioOptions.baseUrl = baseUrl;
  }

  BaseOptions get dioOptions => _dioOptions;
}
