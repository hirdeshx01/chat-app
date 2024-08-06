import 'package:flutter/material.dart';

class RecievedMessages extends StatelessWidget {
  const RecievedMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text('No messages recieved.'),
      ),
    );
  }
}
