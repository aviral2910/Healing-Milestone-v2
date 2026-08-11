import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://healing-milestones-api.onrender.com');
});

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl}) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              // Token fetch failed, proceed without token or log error
            }
          }
          return handler.next(options);
        },
      ),
    );
    
    // Add pretty logger to see beautiful API responses
    bool isRequestColor = true;
    bool isErrorColor = false;
    
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        logPrint: (object) {
          final msg = object.toString();
          
          if (msg.contains('╔') && msg.contains('Request')) {
            isRequestColor = true;
            isErrorColor = false;
          } else if (msg.contains('╔') && msg.contains('Response')) {
            isRequestColor = false;
            isErrorColor = false;
          } else if (msg.contains('╔') && msg.contains('Error')) {
            isRequestColor = false;
            isErrorColor = true;
          }

          if (isErrorColor) {
            print('\x1B[31m$msg\x1B[0m'); // Red for Errors
          } else if (isRequestColor) {
            print('\x1B[33m$msg\x1B[0m'); // Yellow for Requests
          } else {
            print('\x1B[92m$msg\x1B[0m'); // Light Green for Responses
          }
        },
      ),
    );
  }

  Dio get dio => _dio;
}
