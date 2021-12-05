import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_contact.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/model/room.dart';
import 'package:flutter_chatapps/pages/chat_room_page.dart';

import 'package:flutter_chatapps/utils/prefs.dart';

class ListContact extends StatefulWidget {
  const ListContact({Key? key}) : super(key: key);

  @override
  _ListContactState createState() => _ListContactState();
}

class _ListContactState extends State<ListContact> {
  var _controllerEmail = TextEditingController();
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
        .collection('contact')
        .snapshots(includeMetadataChanges: true);
  }

  void addNewContact() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: EdgeInsets.all(16),
          title: Text('Add Contact'),
          children: [
            TextField(
              controller: _controllerEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'email@gmail.com',
              ),
              textAlignVertical: TextAlignVertical.bottom,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () => Navigator.pop(context, 'add'),
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    if (value == 'add') {
      String personUid = await EventPerson.checkEmail(_controllerEmail.text);
      if (personUid != '') {
        EventPerson.getPerson(personUid).then((person) {
          EventContact.addContact(myUid: _myPerson!.uid, person: person);
        });
      }
    }
    _controllerEmail.clear();
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _streamRoom,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  Person person = Person.fromJson(
                      listRoom[index].data() as Map<String, dynamic>);
                  return itemContact(person);
                },
              );
            } else {
              return Center(child: Text('Empty'));
            }
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              addNewContact();
            },
          ),
        ),
      ],
    );
  }

  Widget itemContact(Person person) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FadeInImage(
              placeholder: AssetImage('assets/icon_profile.png'),
              image: NetworkImage(person.photo),
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
      ),
      title: Text(person.name),
      subtitle: Text(person.email),
      trailing: IconButton(
        icon: Icon(Icons.message),
        onPressed: () {
          Room room = Room(
            email: person.email,
            inRoom: false,
            lastChat: '',
            lastDateTime: 0,
            lastUid: '',
            name: person.name,
            photo: person.photo,
            type: '',
            uid: person.uid,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(room: room),
            ),
          );
        },
      ),
    );
  }
}
