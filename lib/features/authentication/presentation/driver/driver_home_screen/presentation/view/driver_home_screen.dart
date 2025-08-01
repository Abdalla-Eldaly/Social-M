import 'package:auto_route/annotations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({super.key});

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  bool _isOnline = false;

  void _toggleOnlineStatus(bool value) {
    setState(() {
      _isOnline = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

      ),
    );
  }
}