import 'package:flutter/material.dart';
import 'package:life_link/models/events_model.dart';

class EventScreen extends StatelessWidget {
  EventScreen({super.key, required this.eventModel});
  EventModel eventModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventModel.date),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text(eventModel.date),
          Text(eventModel.title),
          Text(eventModel.description),
        ],
      ),
    );
  }
}
