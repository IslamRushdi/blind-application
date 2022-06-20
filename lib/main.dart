import 'package:camera_app/screens/banknotes-recognition.dart';
import 'package:camera_app/screens/camera_screeen.dart';
import 'package:camera_app/screens/cloth-detection.dart';
import 'package:camera_app/screens/face-recognition.dart';
import 'package:camera_app/screens/search-for-object.dart';
import 'package:camera_app/screens/stt_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Banknotes(),
      // home: SearchForObject(),
    );
  }
}
