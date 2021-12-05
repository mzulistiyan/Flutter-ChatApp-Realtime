import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatapps/model/chat.dart';
import 'package:flutter_chatapps/model/room.dart';

class EventChatRoom {
  static Future<bool> checkRoomIsExist({
    bool? isSender,
    String? myUid,
    String? personUid,
  }) async {
    DocumentSnapshot response = await FirebaseFirestore.instance
        .collection('person')
        .doc(isSender! ? personUid : myUid)
        .collection('room')
        .doc(isSender ? myUid : personUid)
        .get();
    return response.exists;
  }

  static updateRoom({
    bool? isSender,
    String? myUid,
    String? personUid,
    Room? room,
  }) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(isSender! ? personUid : myUid)
          .collection('room')
          .doc(isSender ? myUid : personUid)
          .update(room!.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static addRoom({
    bool? isSender,
    String? myUid,
    String? personUid,
    Room? room,
  }) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(isSender! ? personUid : myUid)
          .collection('room')
          .doc(isSender ? myUid : personUid)
          .set(room!.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static addChat({
    bool? isSender,
    String? myUid,
    String? personUid,
    Chat? chat,
  }) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(isSender! ? personUid : myUid)
          .collection('room')
          .doc(isSender ? myUid : personUid)
          .collection('chat')
          .doc(chat!.dateTime.toString())
          .set(chat.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> checkIsPersonInRoom({
    String? myUid,
    String? personUid,
  }) async {
    bool inRoom = false;
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .collection('room')
          .doc(personUid)
          .get()
          .catchError((onError) => print(onError));
      inRoom = documentSnapshot['inRoom'];
    } catch (e) {
      print(e);
    }
    return inRoom;
  }

  static updateChatIsRead({
    bool? isSender,
    String? myUid,
    String? personUid,
    String? chatId,
  }) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(isSender! ? personUid : myUid)
          .collection('room')
          .doc(isSender ? myUid : personUid)
          .collection('chat')
          .doc(chatId)
          .update({'isRead': true})
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }
}
