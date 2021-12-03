class Chat {
  final int dateTIme;
  final bool isRead;
  final String message;
  final String type;
  final String uidReceiver;
  final String uidSender;

  Chat({
    required this.dateTIme,
    required this.isRead,
    required this.message,
    required this.type,
    required this.uidReceiver,
    required this.uidSender,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        dateTIme: json['dateTIme'] ?? 0,
        isRead: json['isRead'] ?? false,
        message: json['message'] ?? '',
        type: json['type'] ?? '',
        uidReceiver: json['uidReceiver'] ?? '',
        uidSender: json['uidSender'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'dateTIme': dateTIme,
        'isRead': isRead,
        'message': message,
        'type': type,
        'uidReceiver': uidReceiver,
        'uidSender': uidSender,
      };
}
