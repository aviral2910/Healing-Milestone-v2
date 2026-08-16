import 'package:flutter/foundation.dart';

class Env {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kReleaseMode 
        ? 'https://healing-milestones-api.onrender.com' 
        : 'https://healing-milestones-api.onrender.com', // fallback to prod for now so we don't break local testing unless explicitly passed
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: kReleaseMode 
        ? 'wss://healing-milestones-api.onrender.com' 
        : 'wss://healing-milestones-api.onrender.com',
  );
}
