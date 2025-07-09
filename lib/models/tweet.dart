import 'package:cloud_firestore/cloud_firestore.dart';

class Tweet {
  final String id;
  final String userId;
  final String content;
  final Timestamp timestamp;
  final String? userName; // Represents the user's name
  final int likes; // Number of likes
  final int comments; // Number of comments
  final int retweets; // Number of retweets

  Tweet({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.userName,
    this.likes = 0,
    this.comments = 0,
    this.retweets = 0,
  });

  // Convert Tweet object to a Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp,
      'user_name': userName,
      'likes': likes,
      'comments': comments,
      'retweets': retweets,
    };
  }

  // Convert Firestore document to a Tweet object
  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      userName: map['user_name'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      retweets: map['retweets'] ?? 0,
    );
  }

  // Convert Firestore DocumentSnapshot to a Tweet object
  factory Tweet.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    return Tweet.fromMap(map);
  }
}
