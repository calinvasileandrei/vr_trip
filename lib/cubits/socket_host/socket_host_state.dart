part of 'socket_host_cubit.dart';

enum SocketHostStatus { initial, loading, success, failure }

class SocketHostState extends Equatable {
  final SocketHostStatus status;
  final List<String> messages;
  final bool isConnected;
  final Exception? exception;

  const SocketHostState({
    this.status = SocketHostStatus.initial,
    this.messages = const [],
    this.isConnected = false,
    this.exception,
  });

  @override
  List<Object?> get props => [status, messages, isConnected, exception];

  SocketHostState copyWith({
    SocketHostStatus? status,
    List<String>? messages,
    bool? isConnected,
    Exception? exception,
  }) {
    return SocketHostState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      exception: exception ?? this.exception,
    );
  }
}
