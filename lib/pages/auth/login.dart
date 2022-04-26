import 'package:flutter/material.dart';
import 'register.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chat/pages/workplace.dart';
// import 'package:fl_chat/wsock.dart' as ws;
import 'package:fl_chat/communication.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  // final ws.WbSock wbSock;
  // Login(this.wbSock);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final ws.WbSock wbSock;
  // _LoginState(this.wbSock);
  late FToast fToast;
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  showCustomToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Text(text),
    );

    fToast.showToast(
      gravity: ToastGravity.CENTER,
      child: toast,
      toastDuration: const Duration(seconds: 5),
    );
  }

  void _addNewToken(String _token) async {
    const String key = "user_token";
    await _storage.write(
        key: key,
        value: _token,
        aOptions: _getAndroidOptions()
    );
  }

  Future<String> LoginUser(String userEmail, userPassword) async {
    print('LoginUser..');
    try {
      var request = {
        'event': 'login_user',
        'login': userEmail,
        'pass': userPassword
      };

      var request_str = jsonEncode(request);
      comm.send(request_str);
      return 'd';
    } on Exception catch(e) {
      print(e.toString());
      return e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    comm.addListener('login', _onLoginDataReceived);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    loginController.dispose();
    passwordController.dispose();
    comm.removeListener('login', _onLoginDataReceived);
    super.dispose();
  }

  _onLoginDataReceived(answer) {
    print('islogin: ' + answer.toString());
    try {
        if (answer == 'error_pass') {
          print('error_pass');
          showCustomToast("Password error");
          passwordController.text = '';
        }
        else if (answer == 'error_login') {
          print('error_login');
          showCustomToast("Login error");
          loginController.text = '';
          passwordController.text = '';
        }
        else {
          _addNewToken(answer);
          print('go home');
          Navigator.pushReplacementNamed(
              context,
              "/workplace"
          );
        }
      // }
    } on FormatException catch (e) {
      print('Answer Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Login to RedOctober',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        // child: Column(

        children: <Widget>[
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: loginController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'login',
                  hintText: 'Enter valid login'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            //padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password'),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child:
              TextButton(
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  print('Logggin user');
                  final String hashPass = Crypt.sha256(passwordController.text, salt: '-p-o-l-e-').toString();
                  print(hashPass);
                  final String resp = await LoginUser(loginController.text, hashPass);
                  print(resp);
                },
              ),
          ),
          const SizedBox(
            height: 15,
          ),
          TextButton(
            child: const Text(
              "Create new account",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context,
                  "/register"
              );
              print('new user');
            },
          ),
        ],
        // ),
      ),
    );
  }
}