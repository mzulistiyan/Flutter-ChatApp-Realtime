import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_chat_room.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/event/event_storage.dart';
import 'package:flutter_chatapps/model/chat.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/model/room.dart';
import 'package:flutter_chatapps/pages/fragment/list_chat_room.dart';
import 'package:flutter_chatapps/pages/profile_page.dart';
import 'package:flutter_chatapps/utils/notif_contoller.dart';
import 'package:flutter_chatapps/utils/prefs.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Chat? _selectedChat;

  void getSelectedDefault() {
    setState(() {
      _selectedChat = Chat(
        dateTime: 0,
        isRead: false,
        message: '',
        type: '',
        uidReceiver: '',
        uidSender: '',
      );
    });
  }

  void getMyPerson() async {
    Person? person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    EventChatRoom.setMeInRoom(_myPerson!.uid, widget.room.uid);
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
    bool personInRoom = await EventChatRoom.checkIsPersonInRoom(
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
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
      inRoom: personInRoom,
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
      // await NotifController.sendNotification(
      //   myLastChat: message,
      //   myName: _myPerson!.name,
      //   myUid: _myPerson!.uid,
      //   personToken: token,
      //   photo: _myPerson!.photo,
      //   type: type,
      // );
    }
    print(token);

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

  void pickAndCropImage() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    if (pickedFile != null) {
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        EventStorage.uploadMessageImageAndGetUrl(
          filePhoto: File(croppedFile.path),
          myUid: _myPerson!.uid,
          personUid: widget.room.uid,
        ).then((imageUrl) {
          sendMessage('image', imageUrl);
        });
      }
    }
    getMyPerson();
  }

  void deleteSelectedMessage() {
    if (_selectedChat!.type == 'image') {
      EventStorage.deleteOldFile(_selectedChat!.message);
    }

    EventChatRoom.deleteMessage(
      chatId: _selectedChat!.dateTime.toString(),
      isSender: true,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );
    EventChatRoom.deleteMessage(
      chatId: _selectedChat!.dateTime.toString(),
      isSender: false,
      myUid: _myPerson!.uid,
      personUid: widget.room.uid,
    );
    getSelectedDefault();
  }

  @override
  void initState() {
    getMyPerson();
    WidgetsBinding.instance!.addObserver(this);
    getSelectedDefault();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.addObserver(this);
    EventChatRoom.setMeOutRoom(_myPerson!.uid, widget.room.uid);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('-----------------AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        EventChatRoom.setMeOutRoom(_myPerson!.uid, widget.room.uid);
        print('-----------------AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        EventChatRoom.setMeInRoom(_myPerson!.uid, widget.room.uid);
        print('-----------------AppLifecycleState.resumed');
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
            GestureDetector(
              onTap: () {
                Person person = Person(
                  email: widget.room.email,
                  name: widget.room.name,
                  photo: widget.room.photo,
                  token: '',
                  uid: widget.room.uid,
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
            ),
            SizedBox(width: 8),
            Text(
              widget.room.name,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          SizedBox(
            child: _selectedChat!.message != '' && _selectedChat!.type == 'text'
                ? IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      FlutterClipboard.copy(_selectedChat!.message)
                          .then((value) => print('copied'));
                      getSelectedDefault();
                    },
                  )
                : null,
          ),
          SizedBox(
            child: _selectedChat!.message != '' &&
                    _selectedChat!.uidSender == _myPerson!.uid
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteSelectedMessage();
                    },
                  )
                : null,
          ),
        ],
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
                List<QueryDocumentSnapshot> listChat = snapshot.data!.docs;
                return GroupedListView<QueryDocumentSnapshot, String>(
                  elements: listChat,
                  groupBy: (element) {
                    Chat chat =
                        Chat.fromJson(element.data() as Map<String, dynamic>);
                    DateTime chatDateTime =
                        DateTime.fromMicrosecondsSinceEpoch(chat.dateTime);
                    String dateTime =
                        DateFormat('yyyy/MM/dd').format(chatDateTime);
                    return dateTime;
                  },
                  groupSeparatorBuilder: (value) {
                    String group = '';
                    String today =
                        DateFormat('yyyy/MM/dd').format(DateTime.now());
                    String yesterday = DateFormat('yyyy/MM/dd')
                        .format(DateTime.now().subtract(Duration(days: 1)));
                    if (value == today) {
                      group = 'Today';
                    } else if (value == yesterday) {
                      group = 'Yesterday';
                    } else {
                      group = value;
                    }
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 30,
                        width: 100,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          group,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemComparator: (item1, item2) =>
                      item1.id.compareTo(item2.id),
                  useStickyGroupSeparators: true,
                  floatingHeader: true,
                  reverse: true,
                  order: GroupedListOrder.DESC,
                  indexedItemBuilder: (context, element, index) {
                    final reverseIndex = listChat.length - 1 - index;
                    Chat chat = Chat.fromJson(
                        listChat[reverseIndex].data() as Map<String, dynamic>);
                    return GestureDetector(
                      onLongPress: () {
                        if (chat.message != '') {
                          setState(() {
                            _selectedChat = chat;
                          });
                        }
                      },
                      onTap: () {
                        getSelectedDefault();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: reverseIndex == listChat.length - 1 ? 80 : 0,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          2,
                          16,
                          2,
                        ),
                        color: _selectedChat!.dateTime == chat.dateTime
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.transparent,
                        child: itemChat(chat),
                      ),
                    );
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
                      onPressed: () {
                        pickAndCropImage();
                      }),
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
              : null,
        ),
        SizedBox(width: 4),
        chat.type == 'text' || chat.message == ''
            ? messageText(chat)
            : messageImage(chat),
        SizedBox(width: 4),
        SizedBox(
          child: chat.uidSender == widget.room.uid
              ? Text(dateTime, style: TextStyle(fontSize: 12))
              : null,
        ),
        SizedBox(width: 4),
      ],
    );
  }

  Widget messageText(Chat chat) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: chat.message == ''
            ? Colors.blue.withOpacity(0.3)
            : chat.uidSender == _myPerson!.uid
                ? Colors.blue
                : Colors.blue[800],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            chat.uidSender == _myPerson!.uid ? 10 : 0,
          ),
          topRight: Radius.circular(
            chat.uidSender == _myPerson!.uid ? 0 : 10,
          ),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: ParsedText(
        text: chat.message == '' ? 'message was deleted' : chat.message,
        style: TextStyle(
          color: chat.message == '' ? Colors.grey[600] : Colors.white,
        ),
        parse: [
          MatchText(
              type: ParsedType.EMAIL,
              style: TextStyle(
                color: Colors.yellow,
              ),
              onTap: (url) {
                launch("mailto:" + url);
              }),
          MatchText(
              type: ParsedType.URL,
              style: TextStyle(
                color: Colors.yellow,
              ),
              onTap: (url) async {
                var a = await canLaunch(url);
                if (a) launch(url);
              }),
          MatchText(
              type: ParsedType.PHONE,
              style: TextStyle(
                color: Colors.yellow,
              ),
              onTap: (url) {
                launch("tel:" + url);
              }),
        ],
      ),
    );
  }

  Widget messageImage(Chat chat) {
    return GestureDetector(
      onTap: () => showImageFull(chat.message),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: chat.message == ''
              ? Colors.blue.withOpacity(0.3)
              : chat.uidSender == _myPerson!.uid
                  ? Colors.blue
                  : Colors.blue[800],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              chat.uidSender == _myPerson!.uid ? 10 : 0,
            ),
            topRight: Radius.circular(
              chat.uidSender == _myPerson!.uid ? 0 : 10,
            ),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              chat.uidSender == _myPerson!.uid ? 10 : 0,
            ),
            topRight: Radius.circular(
              chat.uidSender == _myPerson!.uid ? 0 : 10,
            ),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          child: FadeInImage(
            placeholder: AssetImage('assets/icon_profile.png'),
            image: NetworkImage(chat.message),
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
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
    );
  }

  void showImageFull(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          PhotoView(
            enableRotation: true,
            imageProvider: NetworkImage(imageUrl),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
