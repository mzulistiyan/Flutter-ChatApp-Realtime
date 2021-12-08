import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_chat_room.dart';
import 'package:flutter_chatapps/model/chat.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/model/room.dart';
import 'package:flutter_chatapps/pages/chat_room_page.dart';
import 'package:flutter_chatapps/pages/profile_page.dart';
import 'package:flutter_chatapps/utils/prefs.dart';
import 'package:intl/intl.dart';

class ListChat extends StatefulWidget {
  const ListChat({Key? key}) : super(key: key);

  @override
  _ListChatState createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  Person? _myPerson;
  Stream<QuerySnapshot>? _streamRoom;
  void getMyPerson() async {
    Person? person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    _streamRoom = FirebaseFirestore.instance
        .collection('person')
        .doc(_myPerson!.uid)
        .collection('room')
        .snapshots(includeMetadataChanges: true);
  }

  void deleteChatRoom(String personUid) async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          children: [
            ListTile(
              onTap: () => Navigator.pop(context, 'delete'),
              title: Text('Delete Chat Room'),
            ),
            ListTile(
              onTap: () => Navigator.pop(context),
              title: Text('Close'),
            ),
          ],
        );
      },
    );
    if (value == 'delete') {
      EventChatRoom.deleteChatRoom(myUid: _myPerson!.uid, personUid: personUid);
    }
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _streamRoom,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data != null && snapshot.data!.docs.length > 0) {
          List<QueryDocumentSnapshot> listRoom = snapshot.data!.docs;
          return ListView.separated(
            itemCount: listRoom.length,
            separatorBuilder: (context, index) {
              return Divider(thickness: 1, height: 1);
            },
            itemBuilder: (context, index) {
              Room room =
                  Room.fromJson(listRoom[index].data() as Map<String, dynamic>);
              return itemRoom(room);
            },
          );
        } else {
          return Center(child: Text('Empty'));
        }
      },
    );
  }

  Widget itemRoom(Room room) {
    String today = DateFormat('yyyy/MM/dd').format(DateTime.now());
    String yesterday = DateFormat('yyyy/MM/dd')
        .format(DateTime.now().subtract(Duration(days: 1)));
    DateTime roomDateTime =
        DateTime.fromMicrosecondsSinceEpoch(room.lastDateTime);
    String stringLastDateTime = DateFormat('yyyy/MM/dd').format(roomDateTime);
    String time = '';
    if (stringLastDateTime == today) {
      time = DateFormat('HH:mm').format(roomDateTime);
    } else if (stringLastDateTime == yesterday) {
      time = 'Yesterday';
    } else {
      time = DateFormat('yyyy/MM/dd').format(roomDateTime);
    }
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomPage(room: room)),
          );
        },
        onLongPress: () {
          deleteChatRoom(room.uid);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Person person = Person(
                    email: room.email,
                    name: room.name,
                    photo: room.photo,
                    token: '',
                    uid: room.uid,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        person: person,
                        myUid: _myPerson!.uid,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/icon_profile.png'),
                    image: NetworkImage(room.photo),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/icon_profile.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(room.name),
                    Row(
                      children: [
                        SizedBox(
                          child: room.type == 'image'
                              ? Icon(Icons.image,
                                  size: 15, color: Colors.grey[700])
                              : null,
                        ),
                        SizedBox(height: 8),
                        Text(
                          room.type == 'text'
                              ? room.lastChat.length > 20
                                  ? room.lastChat.substring(0, 20) + '...'
                                  : room.lastChat
                              : ' Foto',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$time',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  countUnreadMessage(room.uid, room.lastDateTime),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget countUnreadMessage(String personUid, int lastDateTime) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('person')
          .doc(_myPerson!.uid)
          .collection('room')
          .doc(personUid)
          .collection('chat')
          .snapshots(includeMetadataChanges: true),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SizedBox();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }
        if (snapshot.data == null) {
          return SizedBox();
        }
        List<QueryDocumentSnapshot> listChat = snapshot.data!.docs;

        QueryDocumentSnapshot lastChat = listChat
            .where((element) => element['dateTime'] == lastDateTime)
            .toList()[0];
        Chat lastDataChat =
            Chat.fromJson(lastChat.data() as Map<String, dynamic>);

        if (lastDataChat.uidSender == _myPerson!.uid) {
          return Icon(
            Icons.check,
            size: 20,
            color: lastDataChat.isRead ? Colors.blue : Colors.grey,
          );
        } else {
          int unRead = 0;
          for (var doc in listChat) {
            Chat docChat = Chat.fromJson(doc.data() as Map<String, dynamic>);
            if (!docChat.isRead && docChat.uidSender == personUid) {
              unRead = unRead + 1;
            }
          }
          if (unRead == 0) {
            return SizedBox();
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(4),
              child: Text(
                unRead.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }
        }
      },
    );
  }
}
