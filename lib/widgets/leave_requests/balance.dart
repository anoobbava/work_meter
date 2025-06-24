import 'package:flutter/material.dart';

class LeaveRequestBalance extends StatelessWidget {
  final String? _casualLeave;
  final String? _medicalLeave;
  final String? _earnedLeave;
  LeaveRequestBalance(this._casualLeave, this._medicalLeave, this._earnedLeave);
  @override
  Widget build(BuildContext context) {
    final TextStyle leaveDaysStyle = TextStyle(
        fontSize: 22,
        fontFamily: 'openSans',
        color: Theme.of(context).colorScheme.secondary);
    final TextStyle headerStyle = TextStyle(
        fontSize: 18.0,
        fontFamily: 'openSans',
        color: Theme.of(context).colorScheme.secondary);
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Card(
          color: Theme.of(context).primaryColor,
          elevation: 10,
          child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
              margin: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Image.asset('images/casual_leave_icon.png'),
                  Text(
                    'Casual Leave',
                    style: headerStyle,
                  ),
                  Text(_casualLeave!, style: leaveDaysStyle)
                ],
              )),
        ),
        Card(
          color: Theme.of(context).primaryColor,
          elevation: 10,
          child: Container(
              margin: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Image.asset('images/sick_leave_icon.png'),
                  Text('Sick Leave', style: headerStyle),
                  Text(_medicalLeave!, style: leaveDaysStyle)
                ],
              )),
        ),
        Card(
            color: Theme.of(context).primaryColor,
            elevation: 10,
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Image.asset('images/earned_leave_icon.png'),
                  Text('Earned Leave', style: headerStyle),
                  Text(_earnedLeave!, style: leaveDaysStyle)
                ],
              ),
            )),
      ],
    ));
  }
}
