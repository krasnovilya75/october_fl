import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'wbsock.dart';

///
/// Again, application-level global variable
///
Communication comm = new Communication();

class Communication {
  static final Communication _comm = Communication._internal();

  ///
  /// At first initialization, the player has not yet provided any name
  ///
  String _playerName = "";

  ///
  /// Before the "join" action, the player has no unique ID
  ///
  String _playerID = "";

  factory Communication(){
    return _comm;
  }

  Communication._internal() ;

  ///
  /// Getter to return the player's name
  ///
  String get playerName => _playerName;

  /// ----------------------------------------------------------
  /// Common handler for all received messages, from the server
  /// ----------------------------------------------------------
  _onMessageReceived(serverMessage){
    ///
    /// As messages are sent as a String
    /// let's deserialize it to get the corresponding
    /// JSON object
    ///
    Map message = json.decode(serverMessage);

    switch(message["action_type"]){

      case 'onConnect':
        print( "Connect OK: " + message["result"]);
        Function? callback = _listners['welcome'];
        callback!(message["result"]);
        break;

      case 'registerAnswer':
        print( "registerAnswer: " + message["result"]);
        Function? callback = _listners['register'];
        callback!(message["result"]);
        break;

      case 'loginAnswer':
        print( "loginAnswer: " + message["result"]);
        Function? callback = _listners['login'];
        callback!(message["result"]);
        break;

      case 'roomsAnswer':
        print( "roomsAnswer: " + message["result"]);
        Function? callback = _listners['rooms'];
        callback!(message["result"]);
        break;

      case 'checkUserAnswer':
        print( "checkUserAnswer: " + message["result"]);
        Function? callback = _listners['checkUser'];
        callback!(message["result"]);
        break;

      case 'CreateRoomAnswer':
        print( "CreateRoomAnswer: " + message["result"]);
        Function? callback = _listners['createRoom'];
        callback!(message["result"]);
        break;

      case 'messagesAnswer':
        print( "messagesAnswer: " + message["result"]);
        Function? callback = _listners['messages'];
        callback!(message["result"]);
        break;

      case 'SendMessageAnswer':
        print( "SendMessageAnswer: " + message["result"]);
        Function? callback = _listners['sendMessage'];
        callback!(message["result"]);
        break;

      default:
        _listeners.forEach((Function callback){
          // callback(message);
          // print(callback);
          // callback(serverMessage);
        });
        break;
    }
  }

  /// ----------------------------------------------------------
  /// Common method to send requests to the server
  /// ----------------------------------------------------------
  send(String data){
    sockets.send(data);
  }

  init() async {

    ///
    /// Let's initialize the WebSockets communication
    ///
    await sockets.initCommunication();

    ///
    /// and ask to be notified as soon as a message comes in
    ///
    await sockets.addListener(_onMessageReceived);
  }

  /// ==========================================================
  ///
  /// Listeners to allow the different pages to be notified
  /// when messages come in
  ///
  ObserverList<Function> _listeners = new ObserverList<Function>();
  Map<String, Function> _listners = new Map<String, Function>();

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(String callbackId, Function callback){
    _listeners.add(callback);
    _listners[callbackId] = callback;
  }
  removeListener(String callbackId, Function callback){
    _listeners.remove(callback);
    _listners.remove(callbackId);
  }
}