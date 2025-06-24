import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileCurrentTime extends StatelessWidget {
  final String? workHourFromApi;
  final String? workMinuteFromApi;
  ProfileCurrentTime(this.workHourFromApi, this.workMinuteFromApi);
  @override
  Widget build(BuildContext context) {
    final int workHourPercent =
        workHourFromApi == '' ? 0 : int.parse(workHourFromApi!);
    final String workHour = workHourFromApi == '' ? '00' : workHourFromApi!;
    final String workMinute =
        workMinuteFromApi == '' ? '00' : workMinuteFromApi!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CircularPercentIndicator(
      radius: 180.0,
      lineWidth: 15.0,
      animation: true,
      animationDuration: 1200,
      percent: workHourPercent / 24,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$workHour:$workMinute",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50.0,
                fontFamily: 'digit',
                color: isDark ? Colors.white : Colors.black87),
          ),
          Text(
            "Hours",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 20.0,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      footer: Text(
        "current Time",
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 20.0,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.blue,
      backgroundColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
    );
  }
}
