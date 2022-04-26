import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:fl_chat/communication.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  late FToast fToast;

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

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    comm.addListener('register', _onRegisterDataReceived);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    loginController.dispose();
    passwordController.dispose();
    comm.removeListener('register', _onRegisterDataReceived);
    // super.dispose();
  }

  _onRegisterDataReceived(answer) {
    print('isRegister: ' + answer.toString());
    try {
      if (answer == 'reg_er') {
        print('reg_er');
        showCustomToast("Comrade already in RedOctober");
        passwordController.text = '';
        loginController.text = '';
      }
      else {
        print('go login');
        Navigator.pushReplacementNamed(
            context,
            "/login"
        );
      }
      // }
    } on FormatException catch (e) {
      print('Answer Error');
    }
  }

  Future<String> RegisterUser(String userLogin, userPassword) async {
    print('RegisterUser..');
    try {
      var request = {
        'event': 'register_new_user',
        'login': userLogin,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'New comrade in RedOctober',
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
                  hintText: 'Enter new login'),
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
                hintText: 'Enter secure password'
              ),
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
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                // String regResult = await registerUser(loginController.text, passwordController.text);
                print('Register user');
                final String hashPass = Crypt.sha256(passwordController.text, salt: '-p-o-l-e-').toString();
                print(hashPass);
                final String resp = await RegisterUser(loginController.text, hashPass);
                print(resp);
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}