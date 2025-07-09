class Retweet {
  final String id; // Retweet ID
  final String tweetId; // ID of the original tweet
  final String userId; // ID of the user who retweeted
  final DateTime timestamp; // When the retweet was created

  Retweet({
    required this.id,
    required this.tweetId,
    required this.userId,
    required this.timestamp,
  });

  // Convert Retweet object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tweet_id': tweetId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a Retweet object from a Map (from Firestore)
  factory Retweet.fromMap(Map<String, dynamic> map) {
    return Retweet(
      id: map['id'],
      tweetId: map['tweet_id'],
      userId: map['user_id'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
