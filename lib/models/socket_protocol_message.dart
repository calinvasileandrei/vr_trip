enum SocketActionTypes { play, pause, forward, backward, selectVideo,selectVideoAck,message, toggleVR }

class SocketAction {
  final SocketActionTypes type;
  final String value;

  SocketAction({required this.type, required this.value});

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'value': value,
      };

  // Create an object from JSON
  factory SocketAction.fromJson(Map<String, dynamic> json) => SocketAction(
        type:
            SocketActionTypes.values.firstWhere((e) => e.name == json['type']),
        value: json['value'],
      );
}

class SocketAckMessageResponse{
  final String value;
  final Function ackCallback;

  SocketAckMessageResponse({required this.value, required this.ackCallback});
}
