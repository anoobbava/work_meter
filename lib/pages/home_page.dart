import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// call the UI widgets needed for home page
import '../widgets/common/my_app_bar.dart';
import '../widgets/common/my_drawer.dart';

// call the pages needed for Drawer
import '../widgets/profile/profile_home_page.dart';

import './no_data_found.dart';
import '../services/api_service.dart';
import '../services/environment_config.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // check the API loaded completely or not
  bool isLoading = false;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

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
    // this will call the orange hrm API and retrieve those details.
    _fetchLogData();
    // initNotification();
    // showNotification();
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

  _fetchLogData() async {
    print('called api from HomePage');
    setState(() {
      isLoading = true;
    });

    try {
      // Check if we should refresh data
      final storedData = await ApiService.getStoredUserData();
      final shouldRefresh = ApiService.shouldRefreshData(storedData?['updated_at']);
      
      if (!shouldRefresh) {
        // Show alert that data is already updated
        Alert(
          context: context,
          type: AlertType.info,
          title: "Already updated",
          desc: 'Please refresh after 5 minutes',
          buttons: [
            DialogButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 22,
                    fontFamily: 'openSans'),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch fresh data from API
      final jsonResponse = await ApiService.fetchWorkMeterData();
      print('response from API in HomePage');
      print(jsonResponse);
      
      // if the data is NDF,so no data from API,
      if (jsonResponse['workedTime'] == 'NDF') {
        if (storedData != null) {
          // already data available at our shared preferences.
          // add codes to fetch the data.
          _fetchDataFromSharedPreferences(await SharedPreferences.getInstance());
        } else {
          print('NDF DATA On home Page');
          // redirect to no data page
          _redirectToNoDataPage();
        }
      } else {
        // if user already signed in and we have got data from API, then update the shared preference with this data
        // need to save the data to the shared preferences and pass those data to variables for child widgets
        await ApiService.storeUserData(jsonResponse);
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
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Try to load stored data as fallback
      final storedData = await ApiService.getStoredUserData();
      if (storedData != null) {
        _fetchDataFromSharedPreferences(await SharedPreferences.getInstance());
      } else {
        setState(() {
          isLoading = false;
        });
        // Show error message
        Alert(
          context: context,
          type: AlertType.error,
          title: "Error",
          desc: 'Failed to fetch data: $e',
          buttons: [
            DialogButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 22,
                    fontFamily: 'openSans'),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // _fetchLogData passed to app bar so that, it will be called when refresh button clicked
      appBar: MyAppBar(_fetchLogData),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView(
                children: <Widget>[
                  ProfileHomePage(employeeName, inOut, lastUpdatedAt, workHour,
                      workMinute, weeklyHour, weeklyMinute),
                ],
              ),
            ),
      drawer: MyDrawer(leaveStatus, casualLeave, medicalLeave, earnedLeave,
          attendance, workHour, workMinute, employeeName, inOut),
    );
  }
}
