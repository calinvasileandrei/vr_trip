import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DeviceHostScreen extends HookWidget {
  const DeviceHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final socketHostCubit = useBloc<SocketHostCubit>();
    final messages = useState<List<String>>([]);

    final socket = useMemoized(() => io(
          'http://192.168.1.31:3000', // Replace with your server address
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': true,
          },
        ));

    useEffect(() {
      socket.connect();
      socket.on('message', (data) {
        print('@1message received: $data');
        messages.value = [...messages.value, data];
      });
      return () => socket.disconnect();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
      ),
      body: Center(
          child: Column(
        children: [
          Text('Device Host Screen'),
          ElevatedButton(
            onPressed: () {
              //socket.emit('message', 'Hello from Socket Screen');
            },
            child: Text('Send Message to Server'),
          ),
          Container(
            color: Colors.blueGrey[300],
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.value.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Text('Device ${messages.value[index]}'),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
