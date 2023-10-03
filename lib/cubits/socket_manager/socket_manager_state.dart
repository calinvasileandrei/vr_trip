part of 'socket_manager_cubit.dart';

enum SocketManagerStatus { initial, loading, success, failure }

class SocketManagerState extends Equatable {
  final SocketManagerStatus status;
  final List<String> devices;
  final bool isServerActive;
  final Exception? exception;

  const SocketManagerState(
      {this.status = SocketManagerStatus.initial,
      this.devices = const [],
      this.isServerActive = false,
      this.exception});

  @override
  List<Object?> get props => [status, devices, isServerActive, exception];

  SocketManagerState copyWith({
    SocketManagerStatus? status,
    List<String>? devices,
    bool? isServerActive,
    Exception? exception,
  }) {
    return SocketManagerState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      isServerActive: isServerActive ?? this.isServerActive,
      exception: exception ?? this.exception,
    );
  }
}
