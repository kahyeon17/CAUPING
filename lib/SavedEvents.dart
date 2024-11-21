import 'package:flutter/material.dart';
import 'Colors.dart';

class SavedEvents extends StatefulWidget {
  const SavedEvents({super.key});

  @override
  State<SavedEvents> createState() => _SavedEventsState();
}

class _SavedEventsState extends State<SavedEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('행사 저장 목록',
          style: TextStyle(
              color: CaupingBlack,
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),),
        centerTitle: true,
      ),
    );
  }
}