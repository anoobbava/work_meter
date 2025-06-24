import 'dart:io';

class EnvironmentConfig {
  static const String _developmentKey = 'DEVELOPMENT';
  static const String _apiUrlKey = 'API_URL';
  static const String _apiKeyKey = 'API_KEY';
  
  // Default values
  static const bool _defaultDevelopment = true;
  static const String _defaultApiUrl = 'http://workmeter.herokuapp.com/services/c/';
  static const String _defaultLocalApiUrl = 'http://localhost:3001/workmeter';
  
  // Environment variables
  static bool get isDevelopment {
    return _getEnvironmentVariable(_developmentKey, _defaultDevelopment);
  }
  
  static String get apiUrl {
    if (isDevelopment) {
      return _getEnvironmentVariable(_apiUrlKey, _defaultLocalApiUrl);
    }
    return _getEnvironmentVariable(_apiUrlKey, _defaultApiUrl);
  }
  
  static String? get apiKey {
    return _getEnvironmentVariable(_apiKeyKey, null);
  }
  
  static bool get requiresApiKey {
    return !isDevelopment;
  }
  
  // Helper method to get environment variables
  static T _getEnvironmentVariable<T>(String key, T defaultValue) {
    try {
      final value = Platform.environment[key];
      if (value == null) {
        return defaultValue;
      }
      
      if (T == bool) {
        return (value.toLowerCase() == 'true') as T;
      }
      
      return value as T;
    } catch (e) {
      print('Warning: Could not read environment variable $key: $e');
      print('Using default value: $defaultValue');
      return defaultValue;
    }
  }
  
  // Method to get the appropriate API endpoint
  static String getApiEndpoint(String? userKey) {
    if (isDevelopment) {
      // In development, use local JSON server
      return apiUrl;
    } else {
      // In production, use the key-based endpoint
      if (userKey == null || userKey.isEmpty) {
        throw Exception('API key is required in production mode');
      }
      return '$apiUrl$userKey';
    }
  }
  
  // Method to check if we should bypass authentication
  static bool shouldBypassAuth() {
    return isDevelopment;
  }
} 