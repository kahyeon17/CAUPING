import 'package:cauping/EventCard.dart';
import 'package:flutter/material.dart';
import 'EventInfo.dart';
import 'Colors.dart';

class EventDetailsPage extends StatelessWidget {
  final EventInfo event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('행사 정보',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: EventDetailsCard(event: event),
    );
  }
}
