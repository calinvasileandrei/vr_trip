import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:vr_trip/cubits/socket_manager/socket_manager_cubit.dart';
import 'package:vr_trip/shared/socket_chat/socket_chat.dart';

class DeviceManagementScreen extends HookWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketManagerCubit = useBloc<SocketManagerCubit>();

    useEffect(() {
      socketManagerCubit.startSocketServer();
      return () => socketManagerCubit.stopSocketServer();
    }, []);

    void handleSendMessage(String message) {
      socketManagerCubit.sendMessage(message);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
      ),
      body: Center(
          child: BlocConsumer<SocketManagerCubit, SocketManagerState>(
        listener: (context, state) {
          if (state.status == SocketManagerStatus.success) {
            print('success');
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Text('Server is ${state.isServerActive ? 'active' : 'inactive'}'),
              ElevatedButton(
                  onPressed: () {
                    if (socketManagerCubit.state.isServerActive) {
                      socketManagerCubit.stopSocketServer();
                    } else {
                      socketManagerCubit.startSocketServer();
                    }
                  },
                  child: Text(
                      '${state.isServerActive ? 'Stop' : 'Start'} Server')),
              SocketChat(
                  items: socketManagerCubit.state.devices,
                  handleSendMessage: handleSendMessage),
            ],
          );
        },
      )),
    );
  }
}
