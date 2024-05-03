import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketCalls {
  late IOWebSocketChannel _channel;
  late Stream<dynamic> _stream;
  late StreamSink<dynamic> _sink;


  WebSocketCalls() {
    _channel = IOWebSocketChannel.connect(
        'wss://ws-api.binance.com:443/ws-api/v3');
    _stream = _channel.stream;
    _sink = _channel.sink;
  }

  Future<void> connectToWebSocket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('api_key');
    final String? apiSecret = prefs.getString('api_secret');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final param = 'timestamp=$ts';
    final hmac = Hmac(sha256, utf8.encode(apiSecret!));
    final hash = hmac.convert(utf8.encode(param)).toString();
    final request = {
      "id": "605a6d20-6588-4cb9-afa0-b0ab087507ba",
      "method": "userDataStream.start",
      "params": {
        "apiKey": apiKey,
      }
    };
    _sink.add(json.encode(request));

    // Listen for incoming messages
    _stream.listen((dynamic message) {
      print('Received message: $message');
      // Handle incoming messages here
      // You may want to parse the message and take appropriate actions
    });
  }

  void closeWebSocketConnection() {
    _channel.sink.close();
  }
}
