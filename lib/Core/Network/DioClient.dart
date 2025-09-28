import 'package:dio/dio.dart';

class DioClient {
  static Dio? _testInstance;

  /// Allow tests to override the Dio instance
  static void overrideInstance(Dio dio) {
    _testInstance = dio;
  }

  Dio getInstance() {
    if (_testInstance != null) return _testInstance!;

    return Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
