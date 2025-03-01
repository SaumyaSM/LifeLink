import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LearnAboutOrganDonationScreen extends StatefulWidget {
  const LearnAboutOrganDonationScreen({super.key});

  @override
  State<LearnAboutOrganDonationScreen> createState() =>
      _LearnAboutOrganDonationScreenState();
}

class _LearnAboutOrganDonationScreenState
    extends State<LearnAboutOrganDonationScreen> {
  final List<String> videoURLs = [
    "https://youtu.be/EmitFig6f-M",
    "https://youtu.be/ub3Q3t7Juak",
    "https://youtu.be/5jmSH9uvGPc?si=3MXXBWoDOsY1Rh-k",
    "https://youtu.be/k6xgSB6A9Eg",
    "https://youtu.be/M8vbbBJOMN0?si=vy0BcMlfmsDDJ1s4",
    "https://youtu.be/rBzjBgqrIgM?si=ccO4WuH1-hQrv_79"
  ];

  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = videoURLs
        .map((url) => YoutubePlayerController(
              initialVideoId: YoutubePlayer.convertUrlToId(url) ?? '',
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
            ))
        .toList();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the link")),
      );
    }
  }

  Widget _buildLearnButton(String title, String url, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () => _launchURL(url),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildYouTubePlayer(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controllers[index],
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn About Organ Donation',
          style: TextStyle(color: kPinkColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Center(
            child: Text(
              'Learn Through Trusted Websites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          _buildLearnButton(
              'What is Organ Donation',
              "https://www.organdonation.nhs.uk/helping-you-to-decide/about-organ-donation/",
              kPinkColor),
          _buildLearnButton(
              'What is Transplantation',
              "https://www.who.int/health-topics/transplantation#tab=tab_1",
              Colors.green),
          _buildLearnButton('Living Organ Donors',
              "https://www.ucsfhealth.org/lp/living-organ-donors", Colors.blue),
          _buildLearnButton('How Donation Works',
              "https://www.organdonor.gov/learn/process", Colors.purple),
          _buildLearnButton(
              'Ethics of Organ Donation',
              "https://studycorgi.com/the-ethics-of-organ-donation/",
              Colors.orange),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Learn Through Videos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videoURLs.length,
            itemBuilder: (context, index) => _buildYouTubePlayer(index),
          ),
        ],
      ),
    );
  }
}
