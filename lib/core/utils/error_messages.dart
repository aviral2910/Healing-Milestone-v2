import 'package:dio/dio.dart';

class ErrorMessages {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection Timeout: The request took too long. Let's take a breath and try again.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null && statusCode >= 500) {
            return "Server Error: Our systems are currently healing. Please give us a moment to recover.";
          }
          if (statusCode == 404) {
            return "Not Found: We couldn't find what you were looking for.";
          }
          if (statusCode == 401 || statusCode == 403) {
            return "Unauthorized: Please check your login status.";
          }
          return "Unexpected Error: Something stumbled along the way. Please try again.";
        case DioExceptionType.connectionError:
          return "No Internet Connection: It seems your connection is resting. Please check your wifi and try again.";
        case DioExceptionType.cancel:
          return "Request Cancelled.";
        case DioExceptionType.unknown:
        default:
          return "Unexpected Error: Something stumbled along the way. Please try again.";
      }
    }
    return "Unexpected Error: Something stumbled along the way. Please try again.";
  }
}
