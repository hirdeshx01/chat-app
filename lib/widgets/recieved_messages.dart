import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecievedMessages extends StatelessWidget {
  const RecievedMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
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
            final messageData = loadedMessages[index].data();
            final nextMessageData = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = messageData['userId'];
            final nextMessageUserId =
                nextMessageData != null ? nextMessageData['userId'] : null;

            if (currentMessageUserId == nextMessageUserId) {
              return ChatBubble.next(
                message: messageData['text'],
                isMe: currentMessageUserId == user.uid,
              );
            } else {
              return ChatBubble.first(
                userImage: messageData['userImage'],
                username: messageData['username'],
                message: messageData['text'],
                isMe: currentMessageUserId == user.uid,
              );
            }
          },
        );
      },
    );
  }
}
