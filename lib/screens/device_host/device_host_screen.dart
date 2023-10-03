import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

final devicesProvider = Provider<int>((ref) => 0);

enum DeviceType { advertiser, browser }

class DeviceHostScreen extends HookWidget {
  const DeviceHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = useState<List<String>>([]);

    void addMessage(String value) {
      final currentList = List<String>.from(messages.value);
      currentList.add(value);
      messages.value = currentList;
    }


    final socket = useMemoized(() => io(
      'http://192.168.1.31:3000', // Replace with your server address
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    ));

    useEffect(() {
      socket.connect();

      final messageListener = socket.on('message', (data) {
        print('Received message on SocketScreen: $data');
        addMessage(data);
      });

      return () {
        socket.disconnect();
        //messageListener.cancel();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
      ),
      body: Center(child: Column(
        children: [
          Text('Device Host Screen'),
          ElevatedButton(
            onPressed: () {
              socket.emit('message', 'Hello from Socket Screen');
            },
            child: Text('Send Message to Server'),
          ),
          SocketChat(items: messages.value),
        ],
      )),
    );
  }
}
