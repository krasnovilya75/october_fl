import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chat/pages/auth/login.dart';
// import 'package:fl_chat/wsock.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chat/communication.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  final _storage = const FlutterSecureStorage();
  StreamController<String> streamController = StreamController.broadcast();

  // IOSOptions _getIOSOptions() => IOSOptions(
  //   accountName: _getAccountName(),
  // );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  void _deleteAll() async {
    await _storage.deleteAll(
        // iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions()
    );
  }

  Future<void> _isToken() async {
    final _token = await _storage.read(key: "user_token",
        // iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions()
    );
    if (_token == null) {
      Navigator.pushReplacementNamed(
          context,
          "/login"
      );
    } else {
      var request = {
        'event': 'hello',
        'token': _token,
      };
      var request_str = jsonEncode(request);
      print('req_str: ' + request_str);
      comm.send(request_str);

      Navigator.pushReplacementNamed(
        context,
        "/workplace"
      );
    }
  }

  void initConn() async {
    await comm.init();


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("init welcome");
    initConn();
    comm.addListener('welcome', _onWelcomeDataReceived);

    // _addNewItem();
    // _deleteAll();
  }

  @override
  void dispose() {
    super.dispose();
    comm.removeListener('welcome', _onWelcomeDataReceived);
  }

  _onWelcomeDataReceived(answer) {
    _isToken();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:      // Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/logos/main_logo.png'),
        //     fit: BoxFit.fitWidth,
        //   ),
        // ),
      // ),
      Text('October'),
    );
  }
}