import 'package:flutter/material.dart';
import 'package:presensi_flutter/home-page.dart';
import 'package:presensi_flutter/login-page.dart';
import 'package:presensi_flutter/simpan-page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
