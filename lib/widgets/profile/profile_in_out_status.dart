import 'package:flutter/material.dart';

class ProfileInOutStatus extends StatelessWidget {
  final String? _inOut;
  ProfileInOutStatus(this._inOut);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Text(
        _inOut == 'I' ? 'IN' : 'OUT',
        style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'openSans'),
      ),
    );
  }
}
