import 'dart:io';
import '../services/environment_config.dart';

class AppConfig {
  // Environment configuration
  static const bool _defaultDevelopment = false;
  static const String _defaultProductionApiUrl = 'http://workmeter.herokuapp.com/services/c/';
  static const String _defaultDevelopmentApiUrl = 'http://localhost:3000/api/';
  
  // Get current environment
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;
  static bool get isProduction => !EnvironmentConfig.isDevelopment;
  
  // API Configuration
  static String get apiUrl => EnvironmentConfig.apiUrl;
  static String? get apiKey => EnvironmentConfig.apiKey;
  
  // App Information
  static const String appName = 'Ruby Work Meter';
  static const String appVersion = '1.0.0';
  
  // Timeout configurations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration refreshInterval = Duration(minutes: 5);
  
  // Development mode helpers
  static bool get requiresApiKey => EnvironmentConfig.requiresApiKey;
  static bool get shouldBypassAuth => EnvironmentConfig.shouldBypassAuth();
  
  // Get appropriate API endpoint
  static String getApiEndpoint(String? userKey) {
    return EnvironmentConfig.getApiEndpoint(userKey);
  }
  
  // Print current configuration (for debugging)
  static void printConfig() {
    print('=== App Configuration ===');
    print('Environment: ${isDevelopment ? "Development" : "Production"}');
    print('API URL: $apiUrl');
    print('Requires API Key: $requiresApiKey');
    print('Bypass Auth: $shouldBypassAuth');
    print('=======================');
  }
  
  // Validate configuration
  static bool validateConfig() {
    if (isProduction && apiUrl.isEmpty) {
      print('Error: Production API URL is required');
      return false;
    }
    
    if (isDevelopment && apiUrl.isEmpty) {
      print('Warning: Development API URL is empty, using default localhost');
    }
    
    return true;
  }
} 