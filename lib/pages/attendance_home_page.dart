import 'package:flutter/material.dart';

import '../widgets/attendance/app_bar.dart';
import '../widgets/attendance/attendance_card.dart';
import '../widgets/attendance/total_time.dart';
import '../widgets/attendance/current_time.dart';

class AttendanceHomePage extends StatelessWidget {
  final List? _attendance;
  final String? _workHour;
  final String? _workMinute;
  final String? _inOutStatus;
  AttendanceHomePage(
      this._attendance, this._workHour, this._workMinute, this._inOutStatus);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AttendanceAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460)
                ]
              : [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFFf093fb)
                ],
          ),
        ),
        child: Column(
          children: <Widget>[
            CurrentTime(),
            AttendanceTotalTime(_workHour, _workMinute, _inOutStatus),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Attendance log",
                style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'openSans'),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: AttendanceCard(_attendance),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
