import 'package:flutter/material.dart';

import 'package:fl_chat/pages/system/settings.dart';
import 'package:fl_chat/pages/chat/rooms.dart';
// import 'package:fl_chat/wsock.dart' as ws;

class WorkPlace extends StatefulWidget {
  // final ws.WbSock wbSock;
  // WorkPlace(this.wbSock);

  @override
  _WorkPlaceState createState() => _WorkPlaceState();
}

class _WorkPlaceState extends State<WorkPlace> {
  // final ws.WbSock wbSock;
  // _WorkPlaceState(this.wbSock);
  int selectedPage = 0;
  var _pageOptions = [];

  void initState() {
    _pageOptions = [
      Rooms(),
      Settings()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.message, size: 24), label: 'Rooms'),
            BottomNavigationBarItem(icon: Icon(Icons.group_work, size: 24), label: 'Settings'),
          ],
          selectedItemColor: Colors.blueAccent,
          elevation: 5.0,
          unselectedItemColor: Colors.black54,
          currentIndex: selectedPage,
          backgroundColor: Colors.white,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}