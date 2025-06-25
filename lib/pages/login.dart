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
import '../services/app_theme.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _formAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginPage();
    _initAnimations();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _formAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  Future<void> _checkLoginPage() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (isLoggedIn) {
      _replaceWithHomePage();
    }
  }

  void _replaceWithHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _redirectToNoDataPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => NoData()));
  }

  _checkResponseFromOrgangeHrm(jsonResponse) {
    if (jsonResponse['workedTime'] == 'NDF') {
      print('NDF DATA On Signup Page');
      _redirectToNoDataPage();
    } else {
      _replaceWithHomePage();
    }
  }

  @override
  void dispose() {
    keyController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'How to get your key',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Login to your HRM system',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '2. Navigate to your profile or work meter section',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '3. Copy your unique work meter key',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '4. Paste it in the field above',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.login(keyController.text.trim());
      
      if (result['success']) {
        _checkResponseFromOrgangeHrm(result['data']);
      } else {
        _showErrorMessage(result['message'] ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Network error. Please check your connection.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Header Section
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Animation
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // App Title
                        FadeTransition(
                          opacity: _logoAnimation,
                          child: Column(
                            children: [
                              Text(
                                'WORK METER',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track your work hours effortlessly',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Development Mode Badge
                        if (EnvironmentConfig.isDevelopment)
                          FadeTransition(
                            opacity: _logoAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.warningColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'DEVELOPMENT MODE',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Form Section
                Expanded(
                  flex: 3,
                  child: SlideTransition(
                    position: _formAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Welcome Text
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your work meter key to continue',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Login Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Key Input Field
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark 
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: keyController,
                                    obscureText: !EnvironmentConfig.isDevelopment && !_isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your work meter key';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Work Meter Key',
                                      hintText: EnvironmentConfig.isDevelopment 
                                        ? 'Enter any key (dev mode)' 
                                        : 'Enter your unique key',
                                      prefixIcon: Icon(
                                        Icons.key,
                                        color: AppTheme.primaryColor,
                                      ),
                                      suffixIcon: !EnvironmentConfig.isDevelopment
                                        ? IconButton(
                                            icon: Icon(
                                              _isPasswordVisible 
                                                ? Icons.visibility_off 
                                                : Icons.visibility,
                                              color: AppTheme.primaryColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible = !_isPasswordVisible;
                                              });
                                            },
                                          )
                                        : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleLogin,
                                    child: isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login),
                                            const SizedBox(width: 8),
                                            Text('Sign In'),
                                          ],
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Help Link
                                TextButton.icon(
                                  onPressed: _showInfoDialog,
                                  icon: Icon(
                                    Icons.help_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  label: Text(
                                    'Need help finding your key?',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
