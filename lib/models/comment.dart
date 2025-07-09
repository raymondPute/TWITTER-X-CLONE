class Comment {
  final String id; // Comment ID
  final String tweetId; // ID of the tweet being commented on
  final String userId; // ID of the user who posted the comment
  final String content; // Comment text
  final DateTime timestamp; // When the comment was created

  Comment({
    required this.id,
    required this.tweetId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  // Convert Comment object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tweet_id': tweetId,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a Comment object from a Map (from Firestore)
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      tweetId: map['tweet_id'],
      userId: map['user_id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
