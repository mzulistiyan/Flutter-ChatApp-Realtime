class Chat {
  final int dateTime;
  final bool isRead;
  final String message;
  final String type;
  final String uidReceiver;
  final String uidSender;

  Chat({
    required this.dateTime,
    required this.isRead,
    required this.message,
    required this.type,
    required this.uidReceiver,
    required this.uidSender,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        dateTime: json['dateTime'] ?? 0,
        isRead: json['isRead'] ?? false,
        message: json['message'] ?? '',
        type: json['type'] ?? '',
        uidReceiver: json['uidReceiver'] ?? '',
        uidSender: json['uidSender'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime,
        'isRead': isRead,
        'message': message,
        'type': type,
        'uidReceiver': uidReceiver,
        'uidSender': uidSender,
      };
}
