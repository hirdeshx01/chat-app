import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecievedMessages extends StatelessWidget {
  const RecievedMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No message found'));
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16.0),
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            return Text(loadedMessages[index].data()['text']);
          },
        );
      },
    );
  }
}
