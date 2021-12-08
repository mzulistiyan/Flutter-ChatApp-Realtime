import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_contact.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/model/person.dart';

class ProfilePage extends StatefulWidget {
  final Person person;
  final String myUid;
  const ProfilePage({Key? key, required this.myUid, required this.person})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isContact = false;
  void checkContact() async {
    bool isContact = await EventContact.checkIsMyContact(
      myUid: widget.myUid,
      personUid: widget.person.uid,
    );
    setState(() {
      _isContact = isContact;
    });
  }

  @override
  void initState() {
    checkContact();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('ProfilePerson'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SizedBox(height: 30),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: FadeInImage(
                placeholder: AssetImage('assets/icon_profile.png'),
                image: NetworkImage(widget.person.photo),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/icon_profile.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Name'),
            subtitle: Text(widget.person.name),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text(widget.person.email),
          ),
          Divider(height: 1, thickness: 1),
          SizedBox(height: 16),
          RaisedButton(
            child: Text(_isContact ? 'Delete Contact' : 'Add Contact'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              if (_isContact) {
                EventContact.deleteContact(
                  myUid: widget.myUid,
                  personUid: widget.person.uid,
                );
                checkContact();
              } else {
                EventPerson.getPerson(widget.person.uid).then((person) {
                  EventContact.addContact(myUid: widget.myUid, person: person);
                  checkContact();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
