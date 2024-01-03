import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi_flutter/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi_flutter/model/login-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("token");
    String? name = prefs.getString("name");

    if (token != null && name != null && token.isNotEmpty && name.isNotEmpty) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  Future<void> login(String email, String password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    final headers = {'Content-Type': 'application/json'};
    var response = await myHttp
        .post(Uri.parse('http://10.0.2.2:8000/api/login'), body: body);

    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email atau Password salah")));
    } else {
      loginResponseModel =
          LoginResponseModel.fromJson(json.decode(response.body));
      saveUser(loginResponseModel!.data.token, loginResponseModel!.data.name);
    }
  }

  Future<void> saveUser(String token, String name) async {
    try {
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } catch (err) {
      print('ERROR: $err');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text("LOGIN")),
                SizedBox(height: 20),
                Text("Email"),
                TextField(
                  controller: emailController,
                ),
                SizedBox(height: 20),
                Text("Password"),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    login(emailController.text, passwordController.text);
                  },
                  child: Text("Masuk"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
