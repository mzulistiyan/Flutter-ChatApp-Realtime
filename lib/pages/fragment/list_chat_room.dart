import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/model/room.dart';
import 'package:flutter_chatapps/pages/chat_room_page.dart';
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
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomPage(room: room)),
          );
        },
        onLongPress: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomPage(room: room),
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
                        SizedBox(height: 4),
                        Text(
                          room.type == 'text'
                              ? room.lastChat.length > 20
                                  ? room.lastChat.substring(0, 20) + '...'
                                  : room.lastChat
                              : ' <Image>',
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
                    '${room.lastDateTime}',
                  ),
                  Text(
                    'Badge',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
