import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String? idToken = await user.getIdToken();

      if (idToken != null && idToken.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $idToken";
      }
    }

    return handler.next(options);
  }
}
