import 'package:flutter/material.dart';
import 'package:life_link/models/events_model.dart';
import 'package:intl/intl.dart'; // Add this package for date formatting
import 'package:life_link/constants/colors.dart'; // Import the colors file

class EventScreen extends StatelessWidget {
  final EventModel eventModel;

  const EventScreen({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    // Parse the date string to format it nicely
    DateTime? dateTime;
    String formattedDate = eventModel.date;

    try {
      dateTime = DateTime.parse(eventModel.date);
      formattedDate = DateFormat('EEEE, MMMM d, y').format(dateTime);
    } catch (e) {
      // If parsing fails, use the original date string
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kOrangeColor,
        foregroundColor: Colors.white,
        title: Text(
          'Event Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image or color band
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: kGradientHome,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Event Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    eventModel.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Event details card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: kOrangeColor,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kOrangeColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          eventModel.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
