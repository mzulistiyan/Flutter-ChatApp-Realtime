import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_person.dart';

import 'package:flutter_chatapps/event/event_storage.dart';
import 'package:flutter_chatapps/event/event_storage.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/pages/edit_profile_page.dart';
import 'package:flutter_chatapps/pages/forget_password_page.dart';
import 'package:flutter_chatapps/pages/fragment/list_chat_room.dart';
import 'package:flutter_chatapps/pages/fragment/list_contact_room.dart';
import 'package:flutter_chatapps/pages/login_page.dart';
import 'package:flutter_chatapps/utils/prefs.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Person? _myPerson;
  var _controllerPassword = TextEditingController();

  List<Widget> _listFragment = [
    ListChat(),
    ListContact(),
  ];

  void getMyPerson() async {
    Person? person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    if (_myPerson == null) {
      print('Person Null');
    } else {
      print(_myPerson!.email);
    }
  }

  void pickAndCropPhoto() async {
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
            lockAspectRatio: true,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        EventStorage.editPhoto(
          filePhoto: File(croppedFile.path),
          oldUrl: _myPerson!.photo,
          uid: _myPerson!.uid,
        );
        EventPerson.getPerson(_myPerson!.uid).then((person) {
          Prefs.setPerson(person);
        });
      }
    }
    getMyPerson();
  }

  void logout() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('You sure for logout?'),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, 'logout'),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (value == 'logout') {
      Prefs.clear();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void deleteAccount() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: EdgeInsets.all(16),
          title: Text('Delete Account'),
          children: [
            TextField(
              controller: _controllerPassword,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              textAlignVertical: TextAlignVertical.bottom,
              obscureText: true,
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('Delete'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                if (_controllerPassword.text != null &&
                    _controllerPassword.text != '') {
                  Navigator.pop(context, 'delete');
                }
              },
            ),
            OutlineButton(
              child: Text('Close'),
              textColor: Colors.blue,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    if (value == 'delete') {
      Navigator.pop(context);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _myPerson!.email,
        password: _controllerPassword.text,
      );
      if (userCredential != null) {
        userCredential.user!.delete().then((value) {
          EventPerson.deleteAccount(_myPerson!.uid);
        });
      }
      _controllerPassword.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    getMyPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Text('ChatApp Course'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Chat Room'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        drawer: menuDrawer(),
        body: Center(
          child: TabBarView(children: _listFragment),
        ),
      ),
    );
  }

  Widget menuDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/icon_profile.png'),
                    image:
                        NetworkImage(_myPerson == null ? '' : _myPerson!.photo),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/icon_profile.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myPerson == null ? '' : _myPerson!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _myPerson == null ? '' : _myPerson!.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                          person: _myPerson!,
                        )),
              ).then((value) => getMyPerson());
            },
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgetPassword()),
              );
            },
            leading: Icon(Icons.lock),
            title: Text('Reset Password'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pickAndCropPhoto();
            },
            leading: Icon(Icons.image),
            title: Text('Edit Photo'),
            trailing: Icon(Icons.navigate_next),
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {
              deleteAccount();
            },
            leading: Icon(Icons.delete_forever),
            title: Text('Delete Account'),
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {
              logout();
            },
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
