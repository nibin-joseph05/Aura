import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        user = await FirebaseAuth.instance.authStateChanges().first.timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
      }

      if (user != null) {
        final String? idToken = await user.getIdToken(false);
        if (idToken != null && idToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (_) {}

    dev.log(
      '------------------------------------------------------------\n'
      'REQUEST - ${options.method} ${options.baseUrl}${options.path}\n'
      'Headers: Authorization=${options.headers["Authorization"] != null ? "Bearer ***" : "none"}\n'
      'Data: ${options.data}\n'
      '------------------------------------------------------------',
      name: 'HTTP',
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log(
      '------------------------------------------------------------\n'
      'RESPONSE - ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}\n'
      'Data: ${response.data}\n'
      '------------------------------------------------------------',
      name: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log(
      '------------------------------------------------------------\n'
      'ERROR - ${err.response?.statusCode ?? "N/A"} ${err.requestOptions.method} ${err.requestOptions.path}\n'
      'Message: ${err.message}\n'
      'Response: ${err.response?.data}\n'
      '------------------------------------------------------------',
      name: 'HTTP',
    );
    handler.next(err);
  }
}
