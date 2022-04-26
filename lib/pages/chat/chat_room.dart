import 'dart:convert';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:mime/mime.dart';
// import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chat/communication.dart';

class ChatRoom extends StatefulWidget {
  // const ChatRoom({Key? key}) : super(key: key);

  final int roomId;
  final String roomName;
  ChatRoom(this.roomId, this.roomName);

  @override
  _ChatRoomState createState() => _ChatRoomState(this.roomId, this.roomName);
}

class _ChatRoomState extends State<ChatRoom> {
  final int roomId;
  final String roomName;
  _ChatRoomState(this.roomId, this.roomName);

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  final _storage = const FlutterSecureStorage();

  List<types.Message> _messages = [];
  final _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');
  final _userA = const types.User(id: 'sol');
  final _userB = const types.User(id: '18');

  bool flag = false;

  @override
  void initState() {
    super.initState();
    comm.addListener('messages', _onMessagesDataReceived);
    comm.addListener('sendMessage', _onSendMessageDataReceived);

    _loadMessages();
  }

  @override
  void dispose() {
    super.dispose();
    comm.removeListener('messages', _onMessagesDataReceived);
    comm.removeListener('sendMessage', _onSendMessageDataReceived);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.any,
    // );
    //
    // if (result != null && result.files.single.path != null) {
    //   final message = types.FileMessage(
    //     author: _user,
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     id: const Uuid().v4(),
    //     mimeType: lookupMimeType(result.files.single.path!),
    //     name: result.files.single.name,
    //     size: result.files.single.size,
    //     uri: result.files.single.path!,
    //   );
    //
    //   _addMessage(message);
    // }
  }

  void _handleImageSelection() async {
    // final result = await ImagePicker().pickImage(
    //   imageQuality: 70,
    //   maxWidth: 1440,
    //   source: ImageSource.gallery,
    // );
    //
    // if (result != null) {
    //   final bytes = await result.readAsBytes();
    //   final image = await decodeImageFromList(bytes);
    //
    //   final message = types.ImageMessage(
    //     author: _user,
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     height: image.height.toDouble(),
    //     id: const Uuid().v4(),
    //     name: result.name,
    //     size: bytes.length,
    //     uri: result.path,
    //     width: image.width.toDouble(),
    //   );
    //
    //   _addMessage(message);
    // }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    // if (message is types.FileMessage) {
    //   await OpenFile.open(message.uri);
    }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    // final index = _messages.indexWhere((element) => element.id == message.id);
    // final updatedMessage = _messages[index].copyWith(previewData: previewData);
    //
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   setState(() {
    //     _messages[index] = updatedMessage;
    //   });
    // });
  }

  void _handleSendPressed(types.PartialText message) async {
    types.User usr = _user;
    final _token = await _storage.read(key: "user_token",
        aOptions: _getAndroidOptions()
    );
    print('Send Message..');
    try {
      var request = {
        'event': 'send_message',
        'token': _token,
        'mtext': message.text,
        'room_id': roomId,
      };
      var request_str = jsonEncode(request);
      print('req_str: ' + request_str);
      comm.send(request_str);
    } on Exception catch(e) {
      print(e.toString());
    }
  }

  _onMessagesDataReceived(answer) {
    types.User usr;
    try {
      print('Messages: ' + answer.toString());
      Map answerMap = json.decode(answer);
      if (answerMap['get_room_messages'] != null) {
        print(answerMap['get_room_messages']);
        List messages = json.decode(answerMap['get_room_messages']);
        setState(() {
          _messages.clear();
          messages.forEach((mess) =>
          {
            if (mess["is_mine"] == 1) {
              usr = _user
            } else
              {
                usr = _userB
              },
            _messages.add(types.TextMessage(
              author: usr,
              createdAt: DateTime
                  .now()
                  .millisecondsSinceEpoch,
              id: const Uuid().v4(),
              text: mess["mtext"],
            ))
          });
        });
      }
      //   _rooms.clear();
      //   rooms.forEach((j_room) {
      //     print(j_room["id"]);
      //     _rooms.add(RoomItem(
      //         j_room["id"],
      //         j_room["name"],
      //         DateTime.parse(j_room["last_activity"])
      //     ));
      //   });
      // });
    } on FormatException catch (e) {
      print('_onMessagesDataReceived Error');
    }
  }

  _onSendMessageDataReceived(answer) {
    print('sendMessage: ' + answer.toString());
    Map answerMap = json.decode(answer);
    print(answerMap['send_message']);
    _loadMessages();
  }

  void _loadMessages() async {
    try {
      final _token = await _storage.read(key: "user_token",
          aOptions: _getAndroidOptions()
      );
      var request = {
        'event': 'get_messages',
        'token': _token,
        'room_id': roomId
      };
      var request_str = jsonEncode(request);
      print('req_str: ' + request_str);
      comm.send(request_str);
    } on Exception catch(e) {
      print(e.toString());
    }

    // types.User usr;
    // final _token = await _storage.read(key: "user_token",
    //     aOptions: _getAndroidOptions()
    // );
    // final response = await http.post(
    //   Uri.parse('http://10.0.2.2:9091/get_messages'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'token': _token.toString(),
    //     'room_id': roomId.toString(),
    //   }),
    // );
    // print(response.body);
    // var resp = jsonDecode(response.body);
    // if (resp[0]["error"]  == 'token_error') {
    //   print('token_error!!');
    // }
    // else {
    //   print('meesages');
    //   _messages.clear();
    //   resp.forEach((mess) => {
    //     if (mess["is_mine"] == 1) {
    //       usr = _user
    //     } else {
    //       usr = _userB
    //     },
    //     _messages.add(types.TextMessage(
    //       author:  usr,
    //       createdAt: DateTime.now().millisecondsSinceEpoch,
    //       id: const Uuid().v4(),
    //       text: mess["mtext"],
    //     ))
    //   });
    // }
    // setState(() {
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          roomName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      ),
    );
  }

}