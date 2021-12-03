import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/event/event_person.dart';
import 'package:flutter_chatapps/model/person.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var _formKey = GlobalKey<FormState>();
  var _controllerName = TextEditingController();
  var _controllerEmail = TextEditingController();
  var _controllerPassword = TextEditingController();

  void registerAccount() async {
    if (await EventPerson.checkEmail(_controllerEmail.text) == '') {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );
        if (userCredential.user!.uid != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('Register Success'),
            ),
          );
          Person person = Person(
            email: _controllerEmail.text,
            name: _controllerName.text,
            photo: '',
            token: '',
            uid: userCredential.user!.uid,
          );
          EventPerson.addPerson(person);
          await userCredential.user!.sendEmailVerification();
          _controllerName.clear();
          _controllerEmail.clear();
          _controllerPassword.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('Register Failed'),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('The password provided is too weak.'),
            ),
          );
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: Text('The account already exists for that email.'),
            ),
          );
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text('Already have Account ? '),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
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
                          controller: _controllerName,
                          validator: (value) =>
                              value == '' ? "Don't Empty" : null,
                          decoration: InputDecoration(
                            hintText: 'Your Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                        SizedBox(
                          height: 15,
                        ),
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
                          height: 15,
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
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registerAccount();
                            }
                          },
                          child: Text('Register'),
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
