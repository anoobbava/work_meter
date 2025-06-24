import 'package:flutter/material.dart';

import '../../pages/attendance_home_page.dart';
import '../../pages/leave_requests_home_page.dart';
import '../../pages/user_profile.dart';
import '../../pages/about.dart';

class MyDrawer extends StatelessWidget {
  final String? _leaveStatus;
  final String? _casualLeave;
  final String? _medicalLeave;
  final String? _earnedLeave;
  final List? _attendance;
  final String? _workHour;
  final String? _workMinute;
  final String? _profileName;
  final String? _inOutStatus;
  MyDrawer(
      this._leaveStatus,
      this._casualLeave,
      this._medicalLeave,
      this._earnedLeave,
      this._attendance,
      this._workHour,
      this._workMinute,
      this._profileName,
      this._inOutStatus);
  final TextStyle drawerStyle = TextStyle(
    fontFamily: 'roboto',
    fontSize: 18.0,
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            // Attendance
            ListTile(
              leading: Image.asset('images/attendance_icon.png'),
              title: Text(' Attendance', style: drawerStyle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AttendanceHomePage(
                        _attendance, _workHour, _workMinute, _inOutStatus),
                  ),
                );
              },
            ),
            // Leave Requests
            ListTile(
              leading: Image.asset('images/leave_icon.png'),
              title: Text('Leave Requests', style: drawerStyle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LeaveRequestsHomePage(
                        _leaveStatus,
                        _casualLeave,
                        _medicalLeave,
                        _earnedLeave),
                  ),
                );
              },
            ),

            // API Key
            ListTile(
                leading: Image.asset('images/profile_icon.png'),
                title: Text('Profile', style: drawerStyle),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfile(_profileName),
                    ),
                  );
                }),
            // about page
            ListTile(
                leading: Image.asset('images/about_us_icon.png'),
                title: Text('About us', style: drawerStyle),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => About(),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// Todo:
// 1. change the colour of drawer
// 2. check the SafeArea in the drawer
