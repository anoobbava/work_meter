import 'package:flutter/material.dart';

import '../widgets/leave_requests/app_bar.dart';
import '../widgets/leave_requests/leaves.dart';
import '../widgets/leave_requests/balance.dart';
import '../widgets/leave_requests/leave_count.dart';

class LeaveRequestsHomePage extends StatelessWidget {
  final String? _leaves;
  final String? _casualLeave;
  final String? _medicalLeave;
  final String? _earnedLeave;
  LeaveRequestsHomePage(
      this._leaves, this._casualLeave, this._medicalLeave, this._earnedLeave);
  @override
  Widget build(BuildContext context) {
    final int _leaveCount = _leaves?.split(',').length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
        appBar: LeaveRequestsAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [
                    Color(0xFF2c3e50),
                    Color(0xFF34495e),
                    Color(0xFF3498db)
                  ]
                : [
                    Color(0xFF74b9ff),
                    Color(0xFF0984e3),
                    Color(0xFF6c5ce7)
                  ],
            ),
          ),
          child: Column(children: <Widget>[
            LeaveRequestBalance(_casualLeave, _medicalLeave, _earnedLeave),
            // need to display the leave if pending leaves there
            LeaveCount(_leaveCount),
            // need to display leave if pending leaves there, else display happy image
            Expanded(child: LeaveRequestsLeaves(_leaves))
          ]),
        ));
  }
}
