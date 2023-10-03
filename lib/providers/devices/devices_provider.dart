import 'package:hooks_riverpod/hooks_riverpod.dart';

final connectedDevicesProvider = StateNotifierProvider<ConnectedDevicesNotifier,List<String>>((ref) => ConnectedDevicesNotifier());

class ConnectedDevicesNotifier extends StateNotifier<List<String>> {
  ConnectedDevicesNotifier() : super([]);

  void add(String value) {
    final currentList = List<String>.from(state);
    currentList.add(value);
    state = currentList;
  }

  void remove(String value) {
    final currentList = List<String>.from(state);
    currentList.remove(value);
    state = currentList;
  }
}
