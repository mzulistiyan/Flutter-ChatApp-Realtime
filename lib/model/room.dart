class Room {
  final String email;
  final bool inRoom;
  final String lastChat;
  final int lastDateTime;
  final String lastUid;
  final String name;
  final String photo;
  final String type;
  final String uid;

  Room({
    required this.email,
    required this.inRoom,
    required this.lastChat,
    required this.lastDateTime,
    required this.lastUid,
    required this.name,
    required this.photo,
    required this.type,
    required this.uid,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        email: json['email'] ?? '',
        inRoom: json['inRoom'] ?? false,
        lastChat: json['lastChat'] ?? '',
        lastDateTime: json['lastDateTime'] ?? 0,
        lastUid: json['lastUid'] ?? '',
        name: json['name'] ?? '',
        photo: json['photo'] ?? '',
        type: json['type'] ?? '',
        uid: json['uid'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'inRoom': inRoom,
        'lastChat': lastChat,
        'lastDateTime': lastDateTime,
        'lastUid': lastUid,
        'name': name,
        'photo': photo,
        'type': type,
        'uid': uid,
      };
}
