import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance() {
  
  return Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
       'x-api-key': 'reqres-free-v1'
      }

      )
  );
    

  }
}