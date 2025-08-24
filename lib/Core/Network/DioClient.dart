import 'package:dio/dio.dart';

class DioClient {
  Dio getInstance() {
  
  return Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
            'Content-Type': 'application/json',
          },

      )
  );
    

  }
}