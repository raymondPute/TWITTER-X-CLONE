import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            'You must be logged in to view notifications.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final notifications = snapshot.data?.docs ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification =
              notifications[index].data() as Map<String, dynamic>;
              final type = notification['type'] ?? 'unknown';
              final content = notification['content'] ?? 'No content available';
              final timestamp = notification['timestamp'] is Timestamp
                  ? (notification['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              return ListTile(
                leading: Icon(
                  _getNotificationIcon(type),
                  color: Colors.blue,
                ),
                title: Text(
                  content,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${timestamp.toLocal()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                tileColor: Colors.black54,
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  // Helper method to get the icon for different notification types
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'retweet':
        return Icons.replay;
      default:
        return Icons.notifications;
    }
  }
}
