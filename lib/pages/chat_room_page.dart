import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_chat_room.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/model/chat.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/model/room.dart';
import 'package:flutter_chatapps/pages/fragment/list_chat_room.dart';
import 'package:flutter_chatapps/utils/notif_contoller.dart';
import 'package:flutter_chatapps/utils/prefs.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final Room room;
  const ChatRoomPage({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with WidgetsBindingObserver {
  Person? _myPerson;
  Stream<QuerySnapshot>? _streamChat;
  String _inputMessage = '';
  var _controllerMessage = TextEditingController();
  void getMyPerson() async {
    Person? person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });

    _streamChat = FirebaseFirestore.instance
        .collection('person')
        .doc(_myPerson!.uid)
        .collection('room')
        .doc(widget.room.uid)
        .collection('chat')
        .snapshots(includeMetadataChanges: true);
  }

  void sendMessage(String type, String message) async {
    if (type == 'text') _controllerMessage.clear();
    Chat chat = Chat(
      dateTime: DateTime.now().microsecondsSinceEpoch,
      isRead: false,
      message: message,
      type: type,
      uidReceiver: widget.room.uid,
      uidSender: _myPerson!.uid,
    );

    Room roomSender = Room(
      email: _myPerson!.email,
      inRoom: true,
      lastChat: message,
      lastDateTime: chat.dateTime,
      lastUid: _myPerson!.uid,
      name: _myPerson!.name,
      photo: _myPerson!.photo,
      type: type,
      uid: _myPerson!.uid,
    );
    Room roomReceiver = Room(
      email: widget.room.email,
      inRoom: false,
      lastChat: message,
      lastDateTime: chat.dateTime,
      lastUid: _myPerson!.uid,
      name: widget.room.name,
      photo: widget.room.photo,
      type: type,
      uid: widget.room.uid,
    );

    // Sender Room
    bool isSenderRoomExist = await EventChatRoom.checkRoomIsExist(
      isSender: true,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );
    if (isSenderRoomExist) {
      EventChatRoom.updateRoom(
        isSender: true,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
        room: roomSender,
      );
    } else {
      EventChatRoom.addRoom(
        isSender: true,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
        room: roomSender,
      );
    }
    EventChatRoom.addChat(
      chat: chat,
      isSender: true,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );

    // Receiver Room
    bool isReceiverRoomExist = await EventChatRoom.checkRoomIsExist(
      isSender: false,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );
    if (isReceiverRoomExist) {
      EventChatRoom.updateRoom(
        isSender: false,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
        room: roomReceiver,
      );
    } else {
      EventChatRoom.addRoom(
        isSender: false,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
        room: roomReceiver,
      );
    }
    EventChatRoom.addChat(
      chat: chat,
      isSender: false,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );

    String token = await EventPerson.getPersonToken(widget.room.uid);
    if (token != '') {
      //Notif

    }
    print(token);
    bool personInRoom = await EventChatRoom.checkIsPersonInRoom(
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );
    if (personInRoom) {
      EventChatRoom.updateChatIsRead(
        chatId: chat.dateTime.toString(),
        isSender: true,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
      );
      EventChatRoom.updateChatIsRead(
        chatId: chat.dateTime.toString(),
        isSender: false,
        myUid: _myPerson!.uid,
        personUid: widget.room.uid,
      );
    }
  }

  @override
  void initState() {
    getMyPerson();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.addObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('-----------------AppLifecycleState.inactive');
        break;
      case AppLifecycleState.resumed:
        print('-----------------AppLifecycleState.resumed');
        break;
      case AppLifecycleState.paused:
        print('-----------------AppLifecycleState.paused');
        break;
      case AppLifecycleState.detached:
        print('-----------------AppLifecycleState.detached');
        break;
      default:
        print('-----------------default');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: FadeInImage(
                placeholder: AssetImage('assets/icon_profile.png'),
                image: NetworkImage(widget.room.photo),
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
            SizedBox(width: 8),
            Text(
              widget.room.name,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _streamChat,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data != null && snapshot.data!.docs.length > 0) {
                List<QueryDocumentSnapshot> ListChat = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: ListChat.length,
                  itemBuilder: (context, index) {
                    Chat chat = Chat.fromJson(
                        ListChat[index].data() as Map<String, dynamic>);
                    return Container(
                        margin: EdgeInsets.fromLTRB(16, 2, 16, 2),
                        child: itemChat(chat));
                  },
                );
              } else {
                return Center(child: Text('Empty'));
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.blue,
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(Icons.image, color: Colors.white),
                      onPressed: () {}),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: _inputMessage.contains('\n') ? 4 : 8,
                        horizontal: 16,
                      ),
                      child: TextField(
                        controller: _controllerMessage,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _inputMessage = value;
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        sendMessage('text', _controllerMessage.text);
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemChat(Chat chat) {
    DateTime chatDateTime = DateTime.fromMicrosecondsSinceEpoch(chat.dateTime);
    String dateTime = DateFormat('HH:mm').format(chatDateTime);
    if (chat.type == 'text') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: chat.uidSender == _myPerson!.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          SizedBox(
            child: chat.uidSender == _myPerson!.uid && chat.isRead
                ? Icon(Icons.check, size: 20, color: Colors.blue)
                : null,
          ),
          SizedBox(width: 4),
          SizedBox(
              child: chat.uidSender == _myPerson!.uid
                  ? Text(dateTime, style: TextStyle(fontSize: 12))
                  : null),
          SizedBox(width: 4),
          Container(
            decoration: BoxDecoration(
              color: chat.uidSender == _myPerson!.uid
                  ? Colors.blue
                  : Colors.blue[800],
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(chat.uidSender == _myPerson!.uid ? 10 : 0),
                bottomLeft: Radius.circular(10),
                topRight:
                    Radius.circular(chat.uidSender == _myPerson!.uid ? 0 : 10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(9),
            child: Text(
              chat.message,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          SizedBox(
            child: chat.uidSender == widget.room.uid
                ? Text(dateTime, style: TextStyle(fontSize: 12))
                : null,
          ),
          SizedBox(
            width: 4,
          ),
        ],
      );
    } else {
      return Container(
        width: 100,
        height: 50,
        color: Colors.black,
      );
    }
  }
}
