import 'package:flutter/material.dart';

class AttendanceTotalTime extends StatelessWidget {
  final String? _workHour;
  final String? _workMinute;
  final String? _inOutStatus;
  AttendanceTotalTime(this._workHour, this._workMinute, this._inOutStatus);

  @override
  Widget build(BuildContext context) {
    final TextStyle totalTimeStyle = TextStyle(
        fontFamily: 'openSans',
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary);

    final TextStyle totalHoursStyle = TextStyle(
        fontFamily: 'openSans',
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary);
    final bool _inOut = _inOutStatus == 'I' ? true : false;
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      height: 200.0,
      width: MediaQuery.of(context).size.width - 20.0,
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Hours worked today',
                style: totalHoursStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child:
                  Text('$_workHour: $_workMinute Hours', style: totalTimeStyle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {},
                  color:
                      _inOut == true ? Theme.of(context).indicatorColor : null,
                  elevation: 20.0,
                  highlightElevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'You are Inside',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.secondary,
                        fontFamily: 'openSans'),
                  ),
                ),
                MaterialButton(
                  onPressed: () {},
                  colorBrightness: Brightness.dark,
                  color:
                      _inOut == false ? Theme.of(context).indicatorColor : null,
                  elevation: 20.0,
                  highlightElevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'You are Outside',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.secondary,
                        fontFamily: 'openSans'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
