import 'package:flutter/material.dart';
import 'Colors.dart';

class UpdatedEvents extends StatefulWidget {
  const UpdatedEvents({super.key});

  @override
  State<UpdatedEvents> createState() => _UpdatedEventsState();
}

class _UpdatedEventsState extends State<UpdatedEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('행사 등록 목록',
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
