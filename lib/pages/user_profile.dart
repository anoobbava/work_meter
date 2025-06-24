import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import './home_page.dart';

class UserProfile extends StatefulWidget {
  final String? userName;
  const UserProfile(this.userName);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final keyController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    keyController.dispose();
    super.dispose();
  }

  // handles the user input to check it is blank or not
  void _dialogForNoKey(BuildContext context) {
    Toast.show("Please Add the User Key");
    setState(() {
      isLoading = false;
    });
  }

  Widget _displayDarkModeOption() {
    return Switch(
      activeColor: Colors.green,
      inactiveThumbColor: Colors.red,
      // value: darkMode,
      value: Provider.of<AppState>(context).isDarkModeOn,
      onChanged: (bool newValue) {
        Provider.of<AppState>(context).updateTheme(newValue);
      },
    );
  }

  Widget _displayDarkMessage() {
    return Text(
      'dark Mode',
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Theme.of(context).colorScheme.secondary,
          fontFamily: 'openSans'),
    );
  }

  // if there is no internet connection at the time of login, need to display that too.
  _checkActiveNetwork(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateKeyToSharedPreference();
      }
    } on SocketException catch (_) {
      Toast.show("Active Internet Connection needed");
    }
  }

  _updateKeyToSharedPreference() async {
    print('key updated');
    print(keyController.text);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('api_key', keyController.text);
    print('key updated successfully');
    keyController.text = '';
    Alert(
      context: context,
      type: AlertType.success,
      title: 'Key Update Success',
      desc: 'You Data will be refreshed in a minute',
      buttons: [
        DialogButton(
          child: Text(
            'OK',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 22,
                fontFamily: 'openSans'),
          ),
          onPressed: () => _replaceWithHomePage(),
          width: 120,
        ),
      ],
    ).show();
    FocusScope.of(context).unfocus();
    setState(
      () {
        isLoading = false;
      },
    );
  }

  //Handles the User input and check if it is success, then to Details Page
  _processUserInput(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    if (keyController.text == '') {
      return _dialogForNoKey(context);
    } else {
      return _checkActiveNetwork(context);
    }
  }

  // if the key is already there, then we can easily redirect to the home page
  void _replaceWithHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      // for removing the shade from appbar
      centerTitle: true,
      backgroundColor: Colors.transparent,
      bottomOpacity: 0.0,
      elevation: 0.0,
      title: Text(
        'Your Profile',
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            fontFamily: 'openSans'),
      ),
    );
  }

  Widget _displayImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        'images/happy_icon.png',
        width: 300.0,
        height: 150.0,
      ),
    );
  }

  Widget _displayUserName(BuildContext context) {
    return Text(
      widget.userName!,
      style: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
          fontFamily: 'Courgette'),
    );
  }

  Widget _displayTextField() {
    return Container(
      child: TextField(
        controller: keyController,
        style: TextStyle(fontSize: 20.0),
        enableInteractiveSelection: true,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Enter new Key',
          prefixIcon: Icon(Icons.edit),
          fillColor: Colors.white,
          hintStyle: TextStyle(
            fontSize: 22.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _displayButtonToSave() {
    return Center(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Theme.of(context).colorScheme.secondary,
                minimumSize: Size(200.0, 50.0),
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                _processUserInput(context);
              },
              child: Text(
                'Update Key',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Theme.of(context).colorScheme.secondary,
                    fontFamily: 'openSans'),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _displayImage(),
                    _displayUserName(context),
                    _displayDarkModeOption(),
                    _displayDarkMessage(),
                  ],
                ),
              ),
              Container(
                height: size.height - size.height / 2,
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60.0),
                      topRight: Radius.circular(60.0),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.purple, Colors.blue],
                    )),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: _displayTextField(),
                    ),
                    _displayButtonToSave(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
