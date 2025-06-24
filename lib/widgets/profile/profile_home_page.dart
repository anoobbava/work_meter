import 'package:flutter/material.dart';

import './profile_full_name.dart';
import './profile_refresh_time.dart';
import './profile_in_out_status.dart';
import './profile_current_time.dart';
import './profile_week_time.dart';

class ProfileHomePage extends StatelessWidget {
  final String? _employeeName;
  final String? _inOut;
  final String? _status;
  final String? _workHour;
  final String? _workMinute;
  final String? _weeklyHour;
  final String? _weeklyMinute;
  ProfileHomePage(this._employeeName, this._inOut, this._status, this._workHour,
      this._workMinute, this._weeklyHour, this._weeklyMinute);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Container(
          height: 250.0,
          width: screenSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.blue],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60.0),
              bottomRight: Radius.circular(60.0),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ProfileFulName(_employeeName),
                    Container(
                      height: 100.0,
                      width: screenSize.width - 100.0,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Center(
                          child: ProfileRefreshTime(_status),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        ProfileInOutStatus(_inOut),
        Container(
          width: screenSize.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProfileCurrentTime(_workHour, _workMinute),
              ProfileWeekTime(_weeklyHour, _weeklyMinute)
            ],
          ),
        ),
      ],
    );
  }
}
