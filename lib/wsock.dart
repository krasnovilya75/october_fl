import 'dart:async';
// import 'dart:html';

import 'package:web_socket_channel/web_socket_channel.dart';

class WbSock{
  late WebSocketChannel channel;
  // final streamController = StreamController.broadcast();
  late StreamController streamController;

  WbSock() {
    print("init wsock");

    streamController = StreamController.broadcast();
    // streamController.close();
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.65:9091'),);             // 10.0.2.2:9091
    streamController.addStream(channel.stream);
    // streamController.stream.listen((event) { print(event.toString()); });
    // channel.stream.listen((message) {
    //   print(message);
    //   // _channel.sink.add('received!');
    //   // _channel.sink.close(status.goingAway);
    // },
    //   onDone: () {
    //     print('ws channel closed');
    //   },
    // );
  }

  @override
  void dispose() {
    streamController.close();
  }

  void sendm(String mes) {
    channel.sink.add(mes);
  }
}
