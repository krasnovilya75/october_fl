import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

///
/// Application-level global variable to access the WebSockets
///
WebSocketsNotifications sockets = new WebSocketsNotifications();

///
/// Put your WebSockets server IP address and port number
///
const String _SERVER_ADDRESS = "ws://octoberserv.herokuapp.com/"; // "ws://192.168.1.65:9091";

class WebSocketsNotifications {
  static final WebSocketsNotifications _sockets = new WebSocketsNotifications._internal();

  factory WebSocketsNotifications(){
    return _sockets;
  }

  WebSocketsNotifications._internal();

  ///
  /// The WebSocket "open" channel
  ///
  late IOWebSocketChannel _channel;
  // _channel = IOWebSocketChannel();

  ///
  /// Is the connection established?
  ///
  bool _isOn = false;

  ///
  /// Listeners
  /// List of methods to be called when a new message
  /// comes in.
  ///
  ObserverList<Function> _listeners = new ObserverList<Function>();

  /// ----------------------------------------------------------
  /// Initialization the WebSockets connection with the server
  /// ----------------------------------------------------------
  initCommunication() async {
    ///
    /// Just in case, close any previous communication
    ///
    // reset();

    ///
    /// Open a new WebSocket communication
    ///
    try {
      _channel =  await IOWebSocketChannel.connect(_SERVER_ADDRESS);

      ///
      /// Start listening to new notifications / messages
      ///
      _channel.stream.listen(_onReceptionOfMessageFromServer);
    } catch(e){
      ///
      /// General error handling
      /// TODO
      ///
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset(){
    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.close();
        _isOn = false;
      }
    }
  }

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String message){
    if (_channel != null){
      if (_channel.sink != null && _isOn){
        _channel.sink.add(message);
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback){
    _listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message){
    _isOn = true;
    _listeners.forEach((Function callback){
      callback(message);
    });
  }
}