import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _officeLatPref = 'office_latitude';
  static const String _officeLngPref = 'office_longitude';
  static const String _officeRadiusPref = 'office_radius';
  static const String _allowRemoteWorkPref = 'allow_remote_work';
  
  // Default office location (can be configured per company)
  static const double defaultOfficeLatitude = 37.7749;
  static const double defaultOfficeLongitude = -122.4194;
  static const double defaultOfficeRadius = 100.0; // 100 meters
  
  /// Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    // Also request background location for continuous tracking
    await Permission.locationAlways.request();
    
    return true;
  }
  
  /// Get current device location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
  
  /// Get address from coordinates
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'Unknown location';
  }
  
  /// Calculate distance between two points in meters
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  /// Check if user is within office location
  static Future<LocationValidationResult> validateLocationForCheckIn() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) {
        return LocationValidationResult(
          isValid: false,
          message: 'Unable to get current location',
          distance: 0,
          address: '',
        );
      }
      
      // Get office coordinates from preferences
      final prefs = await SharedPreferences.getInstance();
      double officeLatitude = prefs.getDouble(_officeLatPref) ?? defaultOfficeLatitude;
      double officeLongitude = prefs.getDouble(_officeLngPref) ?? defaultOfficeLongitude;
      double officeRadius = prefs.getDouble(_officeRadiusPref) ?? defaultOfficeRadius;
      bool allowRemoteWork = prefs.getBool(_allowRemoteWorkPref) ?? false;
      
      double distance = calculateDistance(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );
      
      String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      bool isWithinOffice = distance <= officeRadius;
      
      return LocationValidationResult(
        isValid: isWithinOffice || allowRemoteWork,
        message: isWithinOffice 
            ? 'You are at office location'
            : allowRemoteWork 
                ? 'Remote work allowed'
                : 'You are ${distance.toStringAsFixed(0)}m away from office',
        distance: distance,
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return LocationValidationResult(
        isValid: false,
        message: 'Location validation failed: $e',
        distance: 0,
        address: '',
      );
    }
  }
  
  /// Set office location
  static Future<void> setOfficeLocation(double latitude, double longitude, double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_officeLatPref, latitude);
    await prefs.setDouble(_officeLngPref, longitude);
    await prefs.setDouble(_officeRadiusPref, radius);
  }
  
  /// Get office location
  static Future<OfficeLocation> getOfficeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return OfficeLocation(
      latitude: prefs.getDouble(_officeLatPref) ?? defaultOfficeLatitude,
      longitude: prefs.getDouble(_officeLngPref) ?? defaultOfficeLongitude,
      radius: prefs.getDouble(_officeRadiusPref) ?? defaultOfficeRadius,
    );
  }
  
  /// Set remote work permission
  static Future<void> setRemoteWorkAllowed(bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_allowRemoteWorkPref, allowed);
  }
  
  /// Check if remote work is allowed
  static Future<bool> isRemoteWorkAllowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_allowRemoteWorkPref) ?? false;
  }
  
  /// Track location for attendance (can be called periodically)
  static Future<LocationTrackingData?> trackLocation() async {
    Position? position = await getCurrentLocation();
    if (position == null) return null;
    
    String address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    return LocationTrackingData(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      timestamp: DateTime.now(),
      accuracy: position.accuracy,
    );
  }
}

class LocationValidationResult {
  final bool isValid;
  final String message;
  final double distance;
  final String address;
  final double? latitude;
  final double? longitude;
  
  LocationValidationResult({
    required this.isValid,
    required this.message,
    required this.distance,
    required this.address,
    this.latitude,
    this.longitude,
  });
}

class OfficeLocation {
  final double latitude;
  final double longitude;
  final double radius;
  
  OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}

class LocationTrackingData {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final double accuracy;
  
  LocationTrackingData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    required this.accuracy,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };
  }
} 