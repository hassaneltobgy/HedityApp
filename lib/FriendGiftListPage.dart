import 'package:flutter/material.dart';

class FriendGiftListPage extends StatelessWidget {
  final String friendName;

  FriendGiftListPage({required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Gift List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text('Display $friendName\'s gift list here.', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
