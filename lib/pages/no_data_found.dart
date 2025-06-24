import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(200.0),
            bottomRight: Radius.circular(200.0),
          ),
        ),
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/no_data_icon.png'),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text(
                  'Your data is not updated in Orange HRM, please try after some time',
                  style: TextStyle(
                      fontFamily: 'Courgette',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            // Add some space
            SizedBox(
              height: 90.0,
            ),
            Text(
              'Close Application',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            IconButton(
                iconSize: 50.0,
                icon: Image.asset(
                  'images/close_icon.png',
                ),
                onPressed: () {
                  print('onPressed clicked');
                  if (Platform.operatingSystem == 'ios') {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  } else {
                    SystemNavigator.pop();
                  }
                }),
          ],
        ),
      ),
    ));
  }
}
