import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.now();
    final String currentTime = DateFormat('hh:mm a').format(dateTime);
    final String currentDate = DateFormat('E, d MMM y').format(dateTime);
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Text(
            currentTime,
            style: TextStyle(
                fontSize: 25.0,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontFamily: 'openSans'),
          ),
          Text(
            currentDate,
            style: TextStyle(
                fontSize: 17.0,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontFamily: 'openSans'),
          ),
        ],
      ),
    );
  }
}
