import 'package:flutter/material.dart';

class ProfileFulName extends StatelessWidget {
  final String? fulName;
  ProfileFulName(this.fulName);
  // final TextStyle _nameTextStyle(context) = ;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Welcome $fulName',
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 22.0,
          fontFamily: 'openSans'),
    );
  }
}
