import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Demo",
      theme: ThemeData(primaryColor: Colors.black),
      home: MapScreen(),
    );
  }
}

