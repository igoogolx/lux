import 'package:flutter/material.dart';
import 'package:lux/dashboard.dart';

class Home extends StatefulWidget {

  final String baseUrl;
  final String urlStr;
  final String homeDir;

  const Home(this.homeDir, this.baseUrl, this.urlStr, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:WebViewDashboard(widget.homeDir, widget.baseUrl, widget.urlStr)
    );
  }
}