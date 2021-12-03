import 'package:flutter/material.dart';

class ListChat extends StatefulWidget {
  const ListChat({Key? key}) : super(key: key);

  @override
  _ListChatState createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('List Chat'),
    );
  }
}
