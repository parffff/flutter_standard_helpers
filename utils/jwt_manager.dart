import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:standard_test/core/utils/http_utils.dart';
import 'dart:developer' as developer;

import '../data/data_sources/secure_storage_manager.dart';

class JwtManager {
  Future<void> jwtInterceptor(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final SecureStorage storage = SecureStorage();
    String accessJwt = await storage.getString('accessJwt');

    if (accessJwt.isNotEmpty) {
      final bool isExpired = JwtDecoder.isExpired(accessJwt);
      if (isExpired) {
        final String refreshJwt = await storage.getString('refreshJwt');
        accessJwt = await updateJwt(refresh: refreshJwt);
      }
    }
    options.headers['Authorization'] = 'Bearer $accessJwt';
    return handler.next(options);
  }

  Future<String> updateJwt({required String refresh}) async {
    try {
      final HttpUtils utils = HttpUtils();
      Dio dio = Dio(utils.dioOptions);
      dio.options.headers['Authorization'] = 'Bearer $refresh';
      Response res = await dio.get('/path/to/refresh');
      return res.data;
    } catch (e) {
      developer.log(e.toString());
      return '';
    }
  }
}
