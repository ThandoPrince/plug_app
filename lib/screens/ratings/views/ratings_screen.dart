import 'package:flutter/material.dart';

class RatingScreen extends StatelessWidget {
  final int sessionId;

  const RatingScreen({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Your Service"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Leave a rating for session ID: $sessionId",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
