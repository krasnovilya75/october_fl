import 'package:flutter/material.dart';
import '../../models/ausers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chat/pages/chat/rooms.dart';
// import 'package:fl_chat/wsock.dart' as ws;
import 'package:fl_chat/communication.dart';

class AddRoom extends StatefulWidget {
  // final ws.WbSock wbSock;
  // AddRoom(this.wbSock);

  // const AddRoom({Key key}) : super(key: key);
  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {

  // final ws.WbSock wbSock;
  // _AddRoomState(this.wbSock);

  final userController = TextEditingController();
  final roomNameController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = const FlutterSecureStorage();
  List<AUserItem> _ausers = [];
  var _token;
  late FToast fToast;
  bool isBigRoom = false;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<void> getToken() async  {
    _token =  await _storage.read(key: "user_token",
        // iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions()
    );
    // return token;
  }

  void addUserToRoom() async {
    try {
      print('addUserToRoom');
      try {
        var request = {
          'event': 'check_user_by_login',
          'token': _token,
          'login': userController.text
        };
        var request_str = jsonEncode(request);
        print('req_str: ' + request_str);
        comm.send(request_str);
      } on Exception catch(e) {
        print(e.toString());
      }
    } on Exception catch(e) {
      print(e.toString());
    }
  }

  showAlertDeleteUserDialog(BuildContext context, int userId, String userName) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed:  () {
        deleteUserFromRoom(userId);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete user"),
      content: Text("Are you sure to remove ${userName}?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteUserFromRoom(int userId) async {
    try {
      _ausers.removeWhere((removedUser) => removedUser.id == userId);
      if (_ausers.length > 1) {
        isBigRoom = true;
      }
      else {
        isBigRoom = false;
      }
      setState(() {});
    } on Exception catch(e) {
      print(e.toString());
    }
  }

  void createRoom(String roomName, roomUsers) async {
    print('Create Room..');

    try {
      var request = {
        'event': 'create_room',
        'token': _token,
        'room_name': roomName,
        'room_users': roomUsers,
      };
      var request_str = jsonEncode(request);
      print('req_str: ' + request_str);
      comm.send(request_str);
    } on Exception catch(e) {
      print(e.toString());
    }
    // return 'p';
    // if (response.body != 'token_error') {
    //   Navigator.pushReplacementNamed(
    //       context,
    //       "/workplace"
    //   );
    // }
    // else {
    //   print('token_error');
    // }
    // return response.body;
  }

  showCustomToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
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
    comm.addListener('checkUser', _onCheckUserDataReceived);
    comm.addListener('createRoom', _onCreateRoomDataReceived);
    getToken()
        .then((result) {
      print("result: $_token");
    });
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    comm.removeListener('checkUser', _onCheckUserDataReceived);
    comm.removeListener('createRoom', _onCreateRoomDataReceived);
    super.dispose();
  }

  _onCreateRoomDataReceived(answer) {
    print('createRoom: ' + answer.toString());
    Map answerMap = json.decode(answer);
    print(answerMap['create_room']);
    if (answerMap['create_room'] > 0) {
      Navigator.pushReplacementNamed(
        context,
        "/workplace"
      );
    }
    else {
      print('token_error');
    }
  }

  _onCheckUserDataReceived(answer) {
    try {
      print('CheckUser: ' + answer.toString());
      Map answerMap = json.decode(answer);
      print(answerMap['check_user_by_login']);
      var answerObj = json.decode(answerMap['check_user_by_login']);

      if (answerObj["res_id"]  == -2) {
        print('token_error!!');
      }
      else {
        print('check auser');
        if (answerObj["res_id"]  == -1) {
          print('no_user');
          showCustomToast("User Error!");
        }
        else {
          bool inList = false;
          _ausers.forEach((_auser) {
            if (_auser.id == answerObj["res_id"] ) {
              inList = true;
            }
          });
          userController.text = '';
          if (!inList) {
            _ausers.add(AUserItem(answerObj["res_id"], answerObj["res"]));
            if (_ausers.length > 1) {
              isBigRoom = true;
            }
            else {
              isBigRoom = false;
            }
            setState(() {});
          }
          else {
            showCustomToast("User in list yet..");
          }
        }
      }
    } on FormatException catch (e) {
      print('_onCheckUserDataReceived Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'Create room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                        child: TextFormField(
                          enabled: isBigRoom,
                          controller: roomNameController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter chat name',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                        child: TextFormField(
                          controller: userController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter user login',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      child: TextButton(
                        child: const Text('Add'),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.teal,
                          onSurface: Colors.grey,
                        ),
                        onPressed: () {
                          addUserToRoom();
                        },
                      )
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(1),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _ausers.length,
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
                                          width: 30,
                                          height: 40,
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
                                              _ausers[index].name,
                                              style: const TextStyle(
                                                fontFamily: 'Ubuntu',
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold ,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                         ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showAlertDeleteUserDialog(
                                    context,
                                    _ausers[index].id,
                                    _ausers[index].name
                                  );
                                  print("showAlertDeleteUserDialog");
                                },
                              );
                            }
                        )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Create room');
          String users = '[';
          if (_ausers.isNotEmpty) {
            _ausers.forEach((_auser) {
              users = users + _auser.id.toString() + ',';
            });
            users = users.substring(0, users.length - 1);
            users = users + ']';
            createRoom(roomNameController.text, users);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}





