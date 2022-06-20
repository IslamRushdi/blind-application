import 'package:socket_io_client/socket_io_client.dart';

class SocketIO {
  late final socket;

  SocketIO() {
    initializeSocket();
  }

  void initializeSocket() {
    socket = io(
        'http://192.168.1.9:5000/',
        OptionBuilder().setTransports([
          "websocket",
        ]) // for Flutter or Dart VM
            .build());
    socket.onConnect((data) {
      print('connected');
    });
    print(socket);
  }
}
