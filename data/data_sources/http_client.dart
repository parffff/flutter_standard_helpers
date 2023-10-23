import 'dart:io';

import 'package:dio/dio.dart';
import 'package:standard_test/core/utils/http_utils.dart';
import 'dart:developer' as developer;

import 'package:standard_test/core/utils/jwt_manager.dart';

class CustomHttpClient {
  final HttpUtils _utils = HttpUtils();
  final JwtManager _manager = JwtManager();

  Future<Response?> get(String path,
      {Map<String, dynamic>? queryParameters, bool isJwtNeed = true}) async {
    try {
      Dio dio = Dio(_utils.dioOptions);
      if (isJwtNeed) {
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: _manager.jwtInterceptor));
      }
      Response res = await dio.get(path, queryParameters: queryParameters);
      return res;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<Response?> post(String path,
      {required Object data, bool isJwtNeed = true}) async {
    try {
      Dio dio = Dio(_utils.dioOptions);
      if (isJwtNeed) {
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: _manager.jwtInterceptor));
      }
      Response res = await dio.post(path, data: data);
      return res;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<Response?> patch(String path,
      {required Object data, bool isJwtNeed = true}) async {
    try {
      Dio dio = Dio(_utils.dioOptions);
      if (isJwtNeed) {
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: _manager.jwtInterceptor));
      }
      Response res = await dio.patch(path, data: data);
      return res;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<Response?> put(String path,
      {required Object data, bool isJwtNeed = true}) async {
    try {
      Dio dio = Dio(_utils.dioOptions);
      if (isJwtNeed) {
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: _manager.jwtInterceptor));
      }
      Response res = await dio.put(path, data: data);
      return res;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<Response?> delete(String path,
      {required Object data, bool isJwtNeed = true}) async {
    try {
      Dio dio = Dio(_utils.dioOptions);
      if (isJwtNeed) {
        dio.interceptors
            .add(InterceptorsWrapper(onRequest: _manager.jwtInterceptor));
      }
      Response res = await dio.delete(path, data: data);
      return res;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<Response?> multipartRequest(String path,
      {required List<File> files,
      ReqTypes reqType = ReqTypes.post,
      Map<String, dynamic> fileds = const {}}) async {
    Dio dio = Dio(_utils.dioOptions);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.contentType = 'multipart/form-data';
      },
    ));

    Object data = FormData.fromMap({});
    late final Response? res;

    switch (reqType) {
      case ReqTypes.post:
        res = await post(path, data: data);
        break;
      case ReqTypes.patch:
        res = await patch(path, data: data);
        break;
      case ReqTypes.put:
        res = await put(path, data: data);
        break;
      case ReqTypes.delete:
        res = await delete(path, data: data);
        break;
      default:
        break;
    }
    return res;
  }
}

enum ReqTypes { post, patch, put, get, delete }
