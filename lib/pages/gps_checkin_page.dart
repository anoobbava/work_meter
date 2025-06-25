import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/app_theme.dart';
import '../app_state.dart';
import 'package:intl/intl.dart';

class GPSCheckinPage extends StatefulWidget {
  @override
  _GPSCheckinPageState createState() => _GPSCheckinPageState();
}

class _GPSCheckinPageState extends State<GPSCheckinPage> 
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isCheckedIn = false;
  LocationValidationResult? _locationResult;
  DateTime? _lastCheckInTime;
  DateTime? _lastCheckOutTime;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkCurrentStatus();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentStatus() async {
    // This would typically check the current check-in status from API
    // For now, we'll use a simple state check
    setState(() {
      _isCheckedIn = false; // This should come from API
    });
  }

  Future<void> _validateLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationValidationResult result = await LocationService.validateLocationForCheckIn();
      
      setState(() {
        _locationResult = result;
        _isLoading = false;
      });

      if (result.isValid) {
        _showLocationValidDialog();
      } else {
        _showLocationInvalidDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorDialog('Failed to validate location: $e');
    }
  }

  void _showLocationValidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8),
              Text('Location Verified'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_locationResult?.message ?? ''),
              SizedBox(height: 8),
              if (_locationResult?.address != null)
                Text(
                  'Address: ${_locationResult!.address}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performCheckInOut();
              },
              child: Text(_isCheckedIn ? 'Check Out' : 'Check In'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationInvalidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Invalid'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_locationResult?.message ?? 'Unable to verify location'),
              SizedBox(height: 8),
              if (_locationResult?.distance != null)
                Text(
                  'Distance from office: ${_locationResult!.distance.toStringAsFixed(0)}m',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCheckInOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      DateTime now = DateTime.now();
      
      if (_isCheckedIn) {
        // Check out
        _lastCheckOutTime = now;
        await NotificationService.showNotification(
          id: 1,
          title: 'Checked Out Successfully',
          body: 'You have been checked out at ${DateFormat('hh:mm a').format(now)}',
        );
      } else {
        // Check in
        _lastCheckInTime = now;
        await NotificationService.showNotification(
          id: 2,
          title: 'Checked In Successfully',
          body: 'You have been checked in at ${DateFormat('hh:mm a').format(now)}',
        );
      }
      
      setState(() {
        _isCheckedIn = !_isCheckedIn;
        _isLoading = false;
      });

      _animationController.reset();
      _animationController.forward();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCheckedIn ? 'Checked In Successfully' : 'Checked Out Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorDialog('Failed to ${_isCheckedIn ? 'check out' : 'check in'}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'GPS Check-in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 40),
          _buildStatusCard(),
          SizedBox(height: 40),
          _buildCheckInButton(),
          SizedBox(height: 30),
          _buildLocationInfo(),
          SizedBox(height: 30),
          _buildTimeInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isCheckedIn ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCheckedIn ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isCheckedIn ? Icons.work : Icons.work_off,
            size: 48,
            color: _isCheckedIn ? Colors.green : Colors.orange,
          ),
          SizedBox(height: 16),
          Text(
            _isCheckedIn ? 'Currently Checked In' : 'Currently Checked Out',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isCheckedIn ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isCheckedIn 
                ? 'You are currently working' 
                : 'Ready to start your work day',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isCheckedIn 
                    ? [Colors.red[400]!, Colors.red[600]!]
                    : [Colors.green[400]!, Colors.green[600]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isCheckedIn ? Colors.red : Colors.green).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _validateLocation,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Icon(
                              _isCheckedIn ? Icons.logout : Icons.login,
                              size: 40,
                              color: Colors.white,
                            ),
                      SizedBox(height: 8),
                      Text(
                        _isLoading 
                            ? 'Validating...' 
                            : _isCheckedIn 
                                ? 'Check Out'
                                : 'Check In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Location Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _locationResult?.message ?? 'Tap check-in to validate location',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          if (_locationResult?.address != null) ...[
            SizedBox(height: 4),
            Text(
              _locationResult!.address,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        if (_lastCheckInTime != null)
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.login, color: Colors.green),
                  SizedBox(height: 8),
                  Text('Last Check In'),
                  Text(
                    DateFormat('hh:mm a').format(_lastCheckInTime!),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        if (_lastCheckInTime != null && _lastCheckOutTime != null)
          SizedBox(width: 16),
        if (_lastCheckOutTime != null)
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Last Check Out'),
                  Text(
                    DateFormat('hh:mm a').format(_lastCheckOutTime!),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 