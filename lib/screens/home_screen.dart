import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/events_model.dart';
import 'package:life_link/screens/event_screen.dart';
import 'package:life_link/services/events_service.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    required this.isDonor,
    required this.organCount,
  });

  bool isDonor;
  int organCount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _upcomingEventsList = [];

  @override
  void initState() {
    super.initState();
    _getUpcomingEvents();
  }

  void _getUpcomingEvents() async {
    // EventService.getEventList().then((value) {
    //   setState(() => _upcomingEventsList = value);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _welcomeBanner(),
          Flexible(
            child: ListView(
              children: [
                // Detail Cards
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _homeDetailsCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.isDonor ? 'You saved' : 'You received',
                              style: _homeDetailsCardTextStyle(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.organCount.toString(),
                                  style: const TextStyle(
                                    color: kRedColor,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  widget.isDonor ? ' lives' : ' organs',
                                  style: _homeDetailsCardTextStyle(),
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/images/heart.png',
                              height: MediaQuery.of(context).size.width * 0.2,
                            ),
                          ],
                        ),
                      ),
                      _homeDetailsCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Learn about\nOrgan Donation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kRedColor,
                                fontSize: 20,
                              ),
                            ),
                            Image.asset(
                              'assets/images/people.png',
                              height: MediaQuery.of(context).size.width * 0.2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Banner
                Image.asset(
                  widget.isDonor
                      ? 'assets/images/make_donation.png'
                      : 'assets/images/find_donation.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
                // Upcoming Events
                _upcomingEvents(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _welcomeBanner() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        gradient: kGradientHome,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 50,
          ),
          const SizedBox(width: 10),
          Text(
            widget.isDonor ? 'WELCOME DONATOR!' : 'WELCOME RECIPIENT!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Container _homeDetailsCard({required child}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kPeachColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _homeDetailsCardTextStyle() {
    return const TextStyle(
      fontSize: 20,
    );
  }

  Widget _upcomingEvents() {
    return AnimatedOpacity(
      opacity: _upcomingEventsList.isNotEmpty
          ? 1.0
          : 1.0, // opacity: _upcomingEventsList.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 700),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'UPCOMING EVENTS',
              style: TextStyle(
                color: kRedColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            //children: _upcomingEventsList.map((eventModel) => Container(eventModel)).toList(),
            children: [
              _upcomingEventCard(
                eventModel: EventModel(
                  date: '12 December 2024',
                  title: 'Donation Awarness Webinar',
                  description: 'Donation Awarness Webinar Organised by the governement',
                ),
              ),
              _upcomingEventCard(
                eventModel: EventModel(
                  date: '12 December 2024',
                  title: 'Donation Awarness Webinar',
                  description: 'Donation Awarness Webinar Organised by the governement',
                ),
              ),
              _upcomingEventCard(
                eventModel: EventModel(
                  date: '12 December 2024',
                  title: 'Donation Awarness Webinar',
                  description: 'Donation Awarness Webinar Organised by the governement',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _upcomingEventCard({required EventModel eventModel}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EventScreen(eventModel: eventModel)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventModel.date,
              style: const TextStyle(
                color: kRedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              eventModel.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(eventModel.description),
          ],
        ),
      ),
    );
  }
}
