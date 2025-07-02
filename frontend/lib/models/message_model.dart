class MessageModel {
  final String id;
  final String message;
  final String idChat;
  final String idUser;
  final DateTime sendTime;

  MessageModel({
    required this.id,
    required this.message,
    required this.idChat,
    required this.idUser,
    required this.sendTime,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] as String,
      message: json['message'] as String,
      idChat: json['id_chat'] as String,
      idUser: json['id_user'] as String,
      sendTime: DateTime.parse(json['send_time'] as String),
    );
  }
}
