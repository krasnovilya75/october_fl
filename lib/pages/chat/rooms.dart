import 'package:flutter/material.dart';
import 'package:fl_chat/wsock.dart' as wsocket;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'chat_room.dart';
import 'add_room.dart';
// import 'package:fl_chat/wsock.dart' as ws;
import 'package:fl_chat/communication.dart';

class RoomItem {
  final int id;
  final String name;
  final DateTime lastActivity;

  const RoomItem(
      this.id,
      this.name,
      this.lastActivity
  );

  void Rprint() {
    print('id: ' + id.toString() + " name: " + name.toString() + " la: " + lastActivity.toString());
  }
}

class Rooms extends StatefulWidget {
  // final ws.WbSock wbSock;
  // Rooms(this.wbSock);

  @override
  _RoomsState createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {

  var _token;
  List<RoomItem> _rooms = [];
  final _storage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<void> getToken() async {
    _token =  await _storage.read(key: "user_token",
        // iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions()
    );
    // return token;
  }

  void updateRooms() async {
    try {
      var request = {
        'event': 'get_rooms',
        'token': _token,
      };
      var request_str = jsonEncode(request);
      print('req_str: ' + request_str);
      comm.send(request_str);
    } on Exception catch(e) {
      print(e.toString());
    }
  }

  @override
  void initState()  {
    super.initState();
    getToken()
        .then((result) {
      print("result: $_token");
      comm.addListener('rooms', _onRoomsDataReceived);
      updateRooms();
    });
  }

  @override
  void dispose() {
    super.dispose();
    comm.removeListener('rooms', _onRoomsDataReceived);
  }

  _onRoomsDataReceived(answer) {
    try {
      print('Rooms: ' + answer.toString());
      Map answerMap = json.decode(answer);
      print(answerMap['get_rooms']);
      List rooms = json.decode(answerMap['get_rooms']);
      setState(() {
        _rooms.clear();
        rooms.forEach((j_room) {
          print(j_room["id"]);
          _rooms.add(RoomItem(
              j_room["id"],
              j_room["name"],
              DateTime.parse(j_room["last_activity"])
          ));
        });
      });
    } on FormatException catch (e) {
      print('_onRoomsDataReceived Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rooms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(1),
        itemCount: _rooms.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                    child: Container(
                      width: 50,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        'https://picsum.photos/seed/746/600',
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 1, 0, 0),
                        child: Text(
                          _rooms[index].name,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.black54,
                            fontWeight: FontWeight.bold ,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(45, 10, 0, 0),
                        child: Text(
                          'Hello World',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatRoom(_rooms[index].id, _rooms[index].name)),
              );
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRoom()),
          );
          // Navigator.pushReplacementNamed(
          //     context,
          //     "/register"
          // );
        },
        label: const Text("+"),
      ),  //icon: Icon(Icons.thumb_up)
    );

  }

}

