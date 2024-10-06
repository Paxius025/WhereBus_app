import 'package:flutter/material.dart';
import 'package:wherebus_app/screens/login_screen.dart';

void main() {
  runApp(WhereBusApp());
}

class WhereBusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhereBus',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(), // Set LoginScreen as the initial screen
    );
  }
}
