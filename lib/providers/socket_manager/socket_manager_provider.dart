import 'package:hooks_riverpod/hooks_riverpod.dart';

final socketManagerProvider = StateNotifierProvider<SocketManagerNotifier,SocketManager>((ref) => SocketManagerNotifier());

class SocketManagerNotifier extends StateNotifier<SocketManager> {
  SocketManagerNotifier() : super(SocketManager());

  void setIsActive(bool value) {
    state._active = value;
  }

  // Devices
  void addDevice (String device){
    final currentList = List<String>.from(state._devices);
    currentList.add(device);
    state._devices = currentList;
  }

  void removeDevice (String device){
    final currentList = List<String>.from(state._devices);
    currentList.remove(device);
    state._devices = currentList;
  }
}


class SocketManager {
  bool _active = false;
  List<String> _devices = ['ciao'];

  get isActive => _active;

  get getDevices => _devices;
}
