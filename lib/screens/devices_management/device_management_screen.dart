import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io/socket_io.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

final devicesProvider = Provider<int>((ref) => 0);

enum DeviceType { advertiser, browser }

class DeviceManagementScreen extends HookWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = useState<List<String>>([]);
    final messages = useState<List<String>>([]);

    void addMessage(String value) {
      final currentList = List<String>.from(messages.value);
      currentList.add(value);
      messages.value = currentList;
    }

    void addItem(String value) {
      final currentList = List<String>.from(devices.value);
      currentList.add(value);
      devices.value = currentList;
    }

    void removeItem(String name){
      final currentList = List<String>.from(devices.value);
      currentList.remove(name);
      devices.value = currentList;
    }

    final socketServer = useMemoized(() => Server());
    void startSocketServer() {
      socketServer.listen(3000); // You can choose any available port
      print('Socket server started on port 3000');
    }

    useEffect(() {
      socketServer.on('connection', (socket) {
        print('Client connected: ${socket.id}');
        addItem(socket.id);

        socket.on('message', (data) {
          print('Received message: $data');
          socket.emit('message', 'Server received your message: $data');
          addMessage(data);
        });

        socket.on('disconnect', (_) {
          print('Client disconnected: ${socket.id}');
          removeItem(socket.id);
        });

        return () {
          socket.disconnect();
        };
      });

      return () {
        socketServer.close();
      };
    }, const []);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: Center(child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              startSocketServer();
            },
            child: Text('Start Socket Server'),
          ),
          SocketChat(items: devices.value),
          SocketChat(items: messages.value),
        ],
      )),
    );
  }
}
