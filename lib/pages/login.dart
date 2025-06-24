import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import './home_page.dart';
import './no_data_found.dart';
import '../services/api_service.dart';
import '../services/environment_config.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // will handle the key from the user via text field
  final keyController = TextEditingController();
  bool isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _checkLoginPage();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _controller.repeat();
    // below for 1 time process
    // _controller.forward();
  }

  Future<void> _checkLoginPage() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (isLoggedIn) {
      _replaceWithHomePage();
    }
  }

// if the key is already there, then we can easily redirect to the home page
  void _replaceWithHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  // will redirect to to the No Data found page
  void _redirectToNoDataPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => NoData()));
  }

  // connection is okay, but workmeter needed fresh data from orange hrm
  // here, response we get is {"workedTime":"NDF","workedAsInt":"0000"}
  // so the user is not entered the office so far
  _checkResponseFromOrgangeHrm(jsonResponse) {
    if (jsonResponse['workedTime'] == 'NDF') {
      print('NDF DATA On Signup Page');
      // redirect to no data page
      _redirectToNoDataPage();
    } else {
      _replaceWithHomePage();
    }
  }

  @override
  void dispose() {
    keyController.dispose();
    _controller.dispose();
    super.dispose();
  }

// calls this method to display the confirmation if the user dont know where to get
// the code
  void _checkOrangeHrm(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Check Hrm Site'),
            content: Text('Login to your Hrm Site and copy the workmeter key.'),
          );
        });
  }

  // will display the header and linear gradient
  Widget _generateHeaderContainer(screenWidth) {
    return Container(
      height: 200,
      width: screenWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[200]!, Colors.orange[300]!],
        ),
        color: Colors.green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(120.0, 120.0),
          bottomRight: Radius.elliptical(120.0, 120.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WORK METER',
              style: TextStyle(
                  fontSize: 25.0,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'openSans'),
            ),
            if (EnvironmentConfig.isDevelopment)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'DEVELOPMENT MODE',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// will display the image for work meter logo
  Widget _geneateWorkMeterLogo() {
    return Center(
      child: ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(curve: Curves.elasticOut, parent: _controller),
        ),
        child: Container(
          width: 180.0,
          height: 180.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

// display the user input
  Widget _acceptCodeFromUser() {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      child: TextField(
        controller: keyController,
        style: TextStyle(fontSize: 20.0, color: Theme.of(context).colorScheme.secondary),
        enableInteractiveSelection: true,
        obscureText: !EnvironmentConfig.isDevelopment, // Show key in development mode
        decoration: InputDecoration(
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary, fontFamily: 'OpenSans'),
          hintText: EnvironmentConfig.isDevelopment ? 'Enter any key (dev mode)' : 'Enter your code',
          prefixIcon: Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  //
  Widget _displayButtonForSignin() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Theme.of(context).colorScheme.secondary,
              minimumSize: Size(150.0, 50.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            onPressed: () {
              _processUserInput(context);
            },
            child: Text(
              'Sign in',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'openSans',
                  color: Theme.of(context).colorScheme.secondary),
            ),
          );
  }

  Widget _displayNoCodeMessage(BuildContext context) {
    return InkWell(
      onTap: () => _checkOrangeHrm(context),
      child: Text(
        "Didn't get the code ?",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'openSans'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _generateHeaderContainer(size.width),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: size.height / 7.5,
                  ),
                  _geneateWorkMeterLogo(),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  _acceptCodeFromUser(),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  _displayButtonForSignin(),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                  ),
                  _displayNoCodeMessage(context)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Handles the User input and check if it is success, then to Details Page
  _processUserInput(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    
    // In development mode, allow empty key
    if (!EnvironmentConfig.isDevelopment && keyController.text == '') {
      return _dialogForNoKey(context);
    } else {
      return _checkInternet(context);
    }
  }

// handles the user input to check it is blank or not
  void _dialogForNoKey(BuildContext context) {
    Toast.show("Please Add the User Key");
    setState(() {
      isLoading = false;
    });
  }

  // if user enters the key is not present in the Hr Server, need to confirm that too
  void _checkForValidKey(BuildContext context) async {
    print('_checkForValidKey');
    var apiKey = keyController.text;
    
    try {
      // Use the new API service
      var jsonResponse = await ApiService.validateApiKey(apiKey);
      
      print('api success');
      return _saveApiKey(jsonResponse);
    } catch (e) {
      print('Error: $e');
      Toast.show("Entered Key is invalid");
      setState(() {
        isLoading = false;
      });
    }
  }

  // if there is no internet connection at the time of login, need to display that too.
  _checkInternet(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return _checkForValidKey(context);
      }
    } on SocketException catch (_) {
      Toast.show("Active Internet Connection needed");
      setState(() {
        isLoading = false;
      });
    }
  }

  // save the Api Key to shared preferences and redirect to page
  _saveApiKey(jsonResponse) async {
    // Store user data using the new API service
    await ApiService.storeUserData(jsonResponse);
    print('key saved successfully');
    _checkResponseFromOrgangeHrm(jsonResponse);
  }
}
