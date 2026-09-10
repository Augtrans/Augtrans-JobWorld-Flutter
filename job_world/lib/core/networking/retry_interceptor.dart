import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {

  final Dio dio;
  final int retries;

  RetryInterceptor({required this.dio, this.retries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    int attempt = err.requestOptions.extra['retry_count'] ?? 0;

    if (attempt < retries && _shouldRetry(err)) {
      attempt++;
      err.requestOptions.extra['retry_count'] = attempt;
      await Future.delayed(Duration(milliseconds: 500 * attempt));
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}