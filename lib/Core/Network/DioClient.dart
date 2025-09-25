import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance() {
  
  return Dio(
    BaseOptions(
      baseUrl: 'http://192.168.10.35:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
            'Content-Type': 'application/json',
          },

      )
  );
    

  }
}