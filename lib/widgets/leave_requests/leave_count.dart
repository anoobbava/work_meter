import 'package:flutter/material.dart';

class LeaveCount extends StatelessWidget {
  // for date to be styled in the pending count

  final int? _leaveCount;
  LeaveCount(this._leaveCount);

  @override
  Widget build(BuildContext context) {
    final TextStyle leavePendingStyle = TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary);
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            ' $_leaveCount Leaves Pending',
            style: leavePendingStyle,
          ),
        ],
      ),
    );
  }
}
