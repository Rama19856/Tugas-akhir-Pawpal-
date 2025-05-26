import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pawpal/starting/info_screen.dart';
import 'package:pawpal/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterfaceScreen extends StatefulWidget {
  @override
  _InterfaceScreenState createState() => _InterfaceScreenState();
}

class _InterfaceScreenState extends State<InterfaceScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  void _checkFirstRun() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

      print("isFirstRun: $isFirstRun"); // Debugging log

      if (isFirstRun) {
        await prefs.setBool('isFirstRun', false);
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InfoScreen()),
            );
          }
        });
      } else {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        });
      }
    } catch (e) {
      print('Error in InterfaceScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/logo.png', width: 300),
      ),
    );
  }
}
