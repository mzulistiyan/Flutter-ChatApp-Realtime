import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/pages/dashboard_page.dart';
import 'package:flutter_chatapps/pages/forget_password_page.dart';
import 'package:flutter_chatapps/pages/register_page.dart';
import 'package:flutter_chatapps/utils/notif_contoller.dart';
import 'package:flutter_chatapps/utils/prefs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();
  var _controllerEmail = TextEditingController();
  var _controllerPassword = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      if (userCredential.user!.uid != null) {
        if (userCredential.user!.emailVerified) {
          print('Success');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('Success'),
            ),
          );
          String token = await NotifController.getTokenFromDevice();
          EventPerson.updatePersonToken(userCredential.user!.uid, token);
          EventPerson.getPerson(userCredential.user!.uid).then((person) {
            Prefs.setPerson(person);
          });
          Future.delayed(Duration(milliseconds: 1700), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          });
          _controllerEmail.clear();
          _controllerPassword.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('Not Verified'),
              action: SnackBarAction(
                label: 'Send Verif',
                onPressed: () async {
                  await userCredential.user!.sendEmailVerification();
                },
              ),
            ),
          );
          print('Not Verified');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('Failed'),
          ),
        );
        print('Failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('No user found for that email.'),
          ),
        );
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('Wrong password provided for that user.'),
          ),
        );
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not have Account ? '),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _controllerEmail,
                          validator: (value) =>
                              value == '' ? "Don't Empty" : null,
                          decoration: InputDecoration(
                            hintText: 'Your Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _controllerPassword,
                          validator: (value) =>
                              value == '' ? "Don't Empty" : null,
                          decoration: InputDecoration(
                            hintText: 'Your Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPassword(),
                              ),
                            );
                          },
                          child: Text('Forget Password ?'),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginWithEmailAndPassword();
                            }
                          },
                          child: Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
