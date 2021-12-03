import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/model/person.dart';
import 'package:flutter_chatapps/pages/forget_password_page.dart';
import 'package:flutter_chatapps/utils/prefs.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Person? _myPerson;

  void getMyPerson() async {
    Person? person = await Prefs.getPerson();
    setState(() {
      _myPerson = person;
    });
    print(_myPerson!.name);
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
        //Method
      }
    }
    getMyPerson();
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
          child: Text('dashboard'),
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
                    image: AssetImage('assets/icon_profile.png'),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
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
            onTap: () {},
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
            onTap: () {},
            leading: Icon(Icons.image),
            title: Text('Edit Photo'),
            trailing: Icon(Icons.navigate_next),
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.delete_forever),
            title: Text('Delete Account'),
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
