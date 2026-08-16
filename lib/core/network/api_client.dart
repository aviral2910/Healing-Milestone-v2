import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://healing-milestones-api.onrender.com');
});

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      ) {
    // Auth interceptor: attach Firebase token to every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken(false);
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              debugPrint('Token fetch failed: $e');
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Only retry on 401 and only once (check for retry marker)
          if (error.response?.statusCode == 401 &&
              error.requestOptions.headers['_retried'] != true) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                final freshToken = await user.getIdToken(true);
                if (freshToken != null) {
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $freshToken';
                  opts.headers['_retried'] =
                      true; // Mark to prevent infinite retry
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                }
              } catch (e) {
                debugPrint('Token refresh retry failed: $e');
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add pretty logger to see beautiful API responses
    bool isRequestColor = true;
    bool isErrorColor = false;

    if (kDebugMode) {
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

            if (msg.contains('Request ║')) {
              isRequestColor = true;
              isErrorColor = false;
            } else if (msg.contains('Response ║')) {
              isRequestColor = false;
              isErrorColor = false;
            } else if (msg.contains('Error ║') ||
                msg.contains('DioException ║')) {
              isRequestColor = false;
              isErrorColor = true;
            }

            if (isErrorColor) {
              print('\x1b[31m$msg\x1b[0m'); // Red for Errors
            } else if (isRequestColor) {
              print('\x1b[33m$msg\x1b[0m'); // Yellow for Requests
            } else {
              print('\x1b[92m$msg\x1b[0m'); // Light Green for Responses
            }
          },
        ),
      );
    }
  }

  Dio get dio => _dio;
}
