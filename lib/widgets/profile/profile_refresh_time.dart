import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileRefreshTime extends StatelessWidget {
  final String? _status;
  ProfileRefreshTime(this._status);

  @override
  Widget build(BuildContext context) {
    DateTime updatedTime = DateTime.parse(_status!);
    final message = DateFormat(' hh:mm a').format(updatedTime);
    return Text(
      'updated on $message',
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          fontFamily: 'openSans'),
    );
  }
}
