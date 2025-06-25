import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// call the UI widgets needed for home page
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_drawer.dart';

// call the pages needed for Drawer
import '../widgets/profile/profile_home_page.dart';

import './no_data_found.dart';
import '../services/api_service.dart';
import '../services/environment_config.dart';
import '../services/app_theme.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // check the API loaded completely or not
  bool isLoading = false;
  bool isRefreshing = false;
  late AnimationController _cardAnimationController;
  late AnimationController _refreshController;
  late AnimationController _progressController;

  // handle all the data from the API end point
  String? workHour;
  String? lastUpdatedAt;
  String? employeeKey;
  String? weeklyHour;
  String? weeklyMinute;
  String? workMinute;
  String? casualLeave;
  String? medicalLeave;
  String? earnedLeave;
  String? managerPending;
  String? youPending;
  String? leaveStatus;
  String? employeeName;
  String? inOut;
  List? attendance;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchLogData();
    // initNotification();
    // showNotification();
  }

  void _initAnimations() {
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _refreshController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Future<void> onSelectNotification(String payload) async {
  //   print('notification');
  //   if (payload != null) {
  //     print('payload not null');
  //     debugPrint('notification payload: ' + payload);
  //   }
  // }

  // showNotification() async {
  //   print('showNotification');
  //   final prefs = await SharedPreferences.getInstance();
  //   var leaves = prefs.getString('leave_status') ?? null;
  //   print(DateTime.now().add(Duration(minutes: 10)));
  //   var android = new AndroidNotificationDetails(
  //     'Channel ID',
  //     'Channel Name',
  //     'channelDescription',
  //     importance: Importance.Max,
  //     priority: Priority.High,
  //   );
  //   var iOS = new IOSNotificationDetails();
  //   var platform = new NotificationDetails(android, iOS);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, 'Leave Remainder', 'Please apply all the leaves', platform,
  //       payload: 'Leave Notification');
  //   print('leaves count');
  //   print(leaves);
  //   if (leaves != null) {
  //     var leaveArrayCount = leaves.split(',').length;
  //     var scheduledNotificationDateTime =
  //         DateTime.now().add(Duration(minutes: 10));
  //     await flutterLocalNotificationsPlugin.schedule(
  //         0,
  //         'Leave Remainder',
  //         'You have $leaveArrayCount leaves, please apply',
  //         // 'Please apply all the leaves',
  //         scheduledNotificationDateTime,
  //         platform,
  //         payload: 'Leave Notification');
  //   }
  // }

  // init all the needs for push notification
  // void initNotification() {
  //   flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  //   // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  //   var initializationSettingsAndroid =
  //       new AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var initializationSettingsIOS = new IOSInitializationSettings();
  //   var initializationSettings = new InitializationSettings(
  //       initializationSettingsAndroid, initializationSettingsIOS);
  //   FlutterLocalNotificationsPlugin().initialize(initializationSettings,
  //       onSelectNotification: onSelectNotification);
  // }

  // will redirect to to the No Data found page
  void _redirectToNoDataPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NoData(),
      ),
    );
  }

  _updateDataToSharedPrefernces(jsonResponse, prefs) async {
    print('updating data to shared pref');
    prefs.setString('in_out', jsonResponse['in_out']);
    prefs.setString('work_hour', jsonResponse['work_hour']);
    prefs.setString('emp_key', jsonResponse['emp_key']);
    prefs.setString('week_hour', jsonResponse['week_hour']);
    prefs.setString('updated_at', jsonResponse['updated_at']);
    prefs.setString('week_minute', jsonResponse['week_minute']);
    prefs.setString('work_minute', jsonResponse['work_minute']);
    prefs.setString('leave_status', jsonResponse['leave_status']);
    prefs.setString('emp_name', jsonResponse['emp_name']);
    prefs.setString('attendance', json.encode(jsonResponse['attendance']));
    prefs.setString('cl', jsonResponse['cl']);
    prefs.setString('ml', jsonResponse['ml']);
    prefs.setString('el', jsonResponse['el']);
  }

  _fetchDataFromSharedPreferences(prefs) async {
    print('fetching data from shared');
    setState(() {
      workHour = prefs.getString('work_hour');
      employeeKey = prefs.getString('emp_key');
      weeklyHour = prefs.getString('week_hour');
      lastUpdatedAt = prefs.getString('updated_at');
      weeklyMinute = prefs.getString('week_minute');
      workMinute = prefs.getString('work_minute');
      casualLeave = prefs.getString('cl');
      medicalLeave = prefs.getString('ml');
      earnedLeave = prefs.getString('el');
      leaveStatus = prefs.getString('leave_status');
      employeeName = prefs.getString('emp_name');
      inOut = prefs.getString('in_out');
      attendance = json.decode(prefs.getString('attendance') ?? '[]');
      isLoading = false;
    });
  }

  bool _isTimeGapGreaterThan5mins(prefs) {
    DateTime currentTime = DateTime.now();
    final updatedTimeFromApi = prefs.getString('updated_at') ?? '';
    if (updatedTimeFromApi == '') {
      return true;
    } else {
      DateTime updatedTime = DateTime.parse(updatedTimeFromApi);
      if (currentTime.difference(updatedTime).inMinutes > 5) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> _fetchLogData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final storedData = await ApiService.getStoredUserData();
      final shouldRefresh = ApiService.shouldRefreshData(storedData?['updated_at']);
      
      if (!shouldRefresh && storedData != null) {
        _showInfoSnackBar('Data is up to date. Refresh again after 5 minutes.');
        _fetchDataFromSharedPreferences(await SharedPreferences.getInstance());
        return;
      }

      final jsonResponse = await ApiService.fetchWorkMeterData();
      
      if (jsonResponse['workedTime'] == 'NDF') {
        if (storedData != null) {
          _fetchDataFromSharedPreferences(await SharedPreferences.getInstance());
        } else {
          _redirectToNoDataPage();
        }
      } else {
        await ApiService.storeUserData(jsonResponse);
        _updateStateWithData(jsonResponse);
        _cardAnimationController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          _progressController.forward();
        });
        _showSuccessSnackBar('Data refreshed successfully!');
      }
    } catch (e) {
      print('Error fetching data: $e');
      final storedData = await ApiService.getStoredUserData();
      if (storedData != null) {
        _fetchDataFromSharedPreferences(await SharedPreferences.getInstance());
        _showErrorSnackBar('Using cached data. Check your internet connection.');
      } else {
        _showErrorSnackBar('Failed to fetch data. Please try again.');
      }
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  void _updateStateWithData(Map<String, dynamic> jsonResponse) {
    setState(() {
      workHour = jsonResponse['work_hour'];
      employeeKey = jsonResponse['emp_key'];
      weeklyHour = jsonResponse['week_hour'];
      lastUpdatedAt = jsonResponse['updated_at'];
      weeklyMinute = jsonResponse['week_minute'];
      workMinute = jsonResponse['work_minute'];
      casualLeave = jsonResponse['cl'];
      medicalLeave = jsonResponse['ml'];
      earnedLeave = jsonResponse['el'];
      leaveStatus = jsonResponse['leave_status'];
      employeeName = jsonResponse['emp_name'];
      inOut = jsonResponse['in_out'];
      attendance = jsonResponse['attendance'];
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    _refreshController.repeat();
    await _fetchLogData();
    _refreshController.stop();
    _refreshController.reset();
  }

  String _formatTime(String? hour, String? minute) {
    if (hour == null || minute == null) return '0h 0m';
    return '${hour}h ${minute}m';
  }

  String _formatLastUpdated(String? lastUpdated) {
    if (lastUpdated == null) return '-';
    try {
      final DateTime dateTime = DateTime.parse(lastUpdated);
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    } catch (e) {
      return lastUpdated;
    }
  }

  double _getDailyProgress() {
    final hours = int.tryParse(workHour ?? '0') ?? 0;
    final minutes = int.tryParse(workMinute ?? '0') ?? 0;
    final totalMinutes = (hours * 60) + minutes;
    const targetMinutes = 8 * 60; // 8 hours = 480 minutes
    return (totalMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  double _getWeeklyProgress() {
    final hours = int.tryParse(weeklyHour ?? '0') ?? 0;
    final minutes = int.tryParse(weeklyMinute ?? '0') ?? 0;
    final totalMinutes = (hours * 60) + minutes;
    const targetMinutes = 40 * 60; // 40 hours = 2400 minutes
    return (totalMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  Widget _buildWelcomeCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employeeName ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: inOut == 'IN' ? AppTheme.successColor : AppTheme.warningColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (inOut == 'IN' ? AppTheme.successColor : AppTheme.warningColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        inOut == 'IN' ? Icons.business : Icons.home,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        inOut == 'IN' ? 'Inside Office' : 'Outside Office',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Current Time Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'OpenSans',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatsCards() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _buildProgressCard(
              'Today\'s Work',
              _formatTime(workHour, workMinute),
              _getDailyProgress(),
              '8 hours target',
              AppTheme.primaryColor,
              Icons.today,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildProgressCard(
              'This Week',
              _formatTime(weeklyHour, weeklyMinute),
              _getWeeklyProgress(),
              '40 hours target',
              AppTheme.secondaryColor,
              Icons.calendar_view_week,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String currentValue,
    double progress,
    String target,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Circle
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 8.0,
                percent: progress * _progressController.value,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      currentValue,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                progressColor: color,
                backgroundColor: color.withValues(alpha: 0.1),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1500,
              );
            },
          ),
          const SizedBox(height: 12),
          
          // Target Text
          Text(
            target,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return FadeTransition(
      opacity: _cardAnimationController,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _buildQuickStatCard(
              'Sessions',
              '${attendance?.length ?? 0}',
              Icons.play_circle_outline,
              AppTheme.primaryColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildOfficeStatusCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickStatCard(
              'Leaves',
              '${((double.tryParse(casualLeave ?? '0') ?? 0) + (double.tryParse(earnedLeave ?? '0') ?? 0) + (double.tryParse(medicalLeave ?? '0') ?? 0)).toInt()}',
              Icons.event_available,
              AppTheme.secondaryColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeStatusCard() {
    final isInOffice = inOut == 'IN';
    final statusText = isInOffice ? 'Inside Office' : 'Outside Office';
    final statusColor = isInOffice ? AppTheme.successColor : AppTheme.warningColor;
    final statusIcon = isInOffice ? Icons.business : Icons.home;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Icon with Pulse Effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse animation for "Inside Office"
                      if (isInOffice)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2000),
                          builder: (context, value, child) {
                            return Container(
                              width: 48 * (0.5 + (value * 0.5)),
                              height: 48 * (0.5 + (value * 0.5)),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1 * (1 - value)),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            );
                          },
                        ),
                      Icon(statusIcon, color: statusColor, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isInOffice ? 'IN' : 'OUT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Status Text
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedCard() {
    return FadeTransition(
      opacity: _cardAnimationController,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.update,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Updated',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatLastUpdated(lastUpdatedAt),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isRefreshing)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(_handleRefresh),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: isLoading && !isRefreshing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your work data...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildProgressStatsCards(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildLastUpdatedCard(),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
      ),
      drawer: MyDrawer(
        leaveStatus,
        casualLeave,
        medicalLeave,
        earnedLeave,
        attendance,
        workHour,
        workMinute,
        weeklyHour,
        weeklyMinute,
        employeeName,
        inOut,
      ),
    );
  }
}
