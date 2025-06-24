import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './environment_config.dart';
import './mock_api_service.dart';

class ApiService {
  static const String _apiKeyPref = 'api_key';
  
  // Get the stored API key from shared preferences
  static Future<String?> _getStoredApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }
  
  // Store API key in shared preferences
  static Future<void> _storeApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }
  
  // Validate API key (for production mode)
  static Future<Map<String, dynamic>> validateApiKey(String apiKey) async {
    if (EnvironmentConfig.isDevelopment) {
      // In development mode, bypass validation and return mock data
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
      var mockResponse = MockApiService.getMockResponse();
      mockResponse['emp_key'] = apiKey; // Use the provided key
      return mockResponse;
    }
    
    // In production mode, validate the key with the actual API
    try {
      final endpoint = EnvironmentConfig.getApiEndpoint(apiKey);
      final response = await http.get(Uri.parse(endpoint));
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        await _storeApiKey(apiKey);
        return jsonResponse;
      } else {
        throw Exception('Invalid API key or server error');
      }
    } catch (e) {
      throw Exception('Failed to validate API key: $e');
    }
  }
  
  // Fetch work meter data
  static Future<Map<String, dynamic>> fetchWorkMeterData() async {
    if (EnvironmentConfig.isDevelopment) {
      // In development mode, try local JSON server first, then fallback to mock data
      try {
        final endpoint = EnvironmentConfig.apiUrl;
        final response = await http.get(Uri.parse(endpoint));
        
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          // If it's a JSON server response, extract the workmeter data
          if (jsonResponse.containsKey('workmeter')) {
            return jsonResponse['workmeter'];
          }
          return jsonResponse;
        }
      } catch (e) {
        print('Local JSON server not available, using mock data: $e');
      }
      
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
      return MockApiService.getMockResponse();
    }
    
    // In production mode, use stored API key
    final apiKey = await _getStoredApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key found. Please login first.');
    }
    
    try {
      final endpoint = EnvironmentConfig.getApiEndpoint(apiKey);
      final response = await http.get(Uri.parse(endpoint));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      throw Exception('Failed to fetch work meter data: $e');
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (EnvironmentConfig.isDevelopment) {
      return true; // Always consider logged in during development
    }
    
    final apiKey = await _getStoredApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }
  
  // Get stored user data
  static Future<Map<String, dynamic>?> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final workHour = prefs.getString('work_hour');
    final empKey = prefs.getString('emp_key');
    final weekHour = prefs.getString('week_hour');
    final updatedAt = prefs.getString('updated_at');
    final weekMinute = prefs.getString('week_minute');
    final workMinute = prefs.getString('work_minute');
    final leaveStatus = prefs.getString('leave_status');
    final empName = prefs.getString('emp_name');
    final inOut = prefs.getString('in_out');
    final attendance = prefs.getString('attendance');
    final cl = prefs.getString('cl');
    final ml = prefs.getString('ml');
    final el = prefs.getString('el');
    
    if (workHour == null) return null;
    
    return {
      'work_hour': workHour,
      'emp_key': empKey,
      'week_hour': weekHour,
      'updated_at': updatedAt,
      'week_minute': weekMinute,
      'work_minute': workMinute,
      'leave_status': leaveStatus,
      'emp_name': empName,
      'in_out': inOut,
      'attendance': attendance != null ? json.decode(attendance) : [],
      'cl': cl,
      'ml': ml,
      'el': el,
    };
  }
  
  // Store user data
  static Future<void> storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setString('in_out', data['in_out'] ?? '');
    prefs.setString('work_hour', data['work_hour'] ?? '');
    prefs.setString('emp_key', data['emp_key'] ?? '');
    prefs.setString('week_hour', data['week_hour'] ?? '');
    prefs.setString('updated_at', data['updated_at'] ?? '');
    prefs.setString('week_minute', data['week_minute'] ?? '');
    prefs.setString('work_minute', data['work_minute'] ?? '');
    prefs.setString('leave_status', data['leave_status'] ?? '');
    prefs.setString('emp_name', data['emp_name'] ?? '');
    prefs.setString('attendance', json.encode(data['attendance'] ?? []));
    prefs.setString('cl', data['cl'] ?? '');
    prefs.setString('ml', data['ml'] ?? '');
    prefs.setString('el', data['el'] ?? '');
  }
  
  // Check if data needs refresh (5 minutes gap)
  static bool shouldRefreshData(String? lastUpdatedAt) {
    if (lastUpdatedAt == null || lastUpdatedAt.isEmpty) {
      return true;
    }
    
    try {
      final updatedTime = DateTime.parse(lastUpdatedAt);
      final currentTime = DateTime.now();
      return currentTime.difference(updatedTime).inMinutes > 5;
    } catch (e) {
      return true;
    }
  }
  
  // Test connection to local JSON server (development only)
  static Future<bool> testLocalServer() async {
    if (!EnvironmentConfig.isDevelopment) {
      return false;
    }
    
    try {
      final endpoint = EnvironmentConfig.apiUrl;
      final response = await http.get(Uri.parse(endpoint));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 