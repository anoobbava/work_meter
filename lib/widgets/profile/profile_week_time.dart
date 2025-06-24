import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileWeekTime extends StatelessWidget {
  final String? _weeklyHour;
  final String? _weeklyMinute;
  ProfileWeekTime(this._weeklyHour, this._weeklyMinute);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 150.0,
      height: 100.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: isDark ? Colors.grey[800] : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Week',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'openSans',
                  color: isDark ? Colors.white : Colors.black87),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              '${_weeklyHour ?? "0"}:${_weeklyMinute ?? "00"}',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'digit',
                  color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
