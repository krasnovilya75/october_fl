import 'package:fl_chat/pages/auth/welcome.dart';
import 'package:fl_chat/pages/auth/register.dart';
import 'package:fl_chat/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:fl_chat/pages/workplace.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // wsocket.wsock _wsock = Null as wsocket.wsock;
  // WbSock ws = WbSock();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Welcome(), //GMapsPage(),
      routes: {
        "/workplace": (_) => WorkPlace(),
        "/welcome": (_) => Welcome(),
        "/login": (_) =>  Login(),
        "/register": (_) =>  Register(),
      },
    );
  }
}