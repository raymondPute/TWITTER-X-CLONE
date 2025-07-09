class Notification {
  final String id; // Notification ID
  final String userId; // User receiving the notification
  final String type; // Notification type (like, comment, retweet, follow)
  final String contentId; // Associated tweet, comment, or user ID
  final String message; // Notification message
  final DateTime timestamp; // When the notification was created

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.contentId,
    required this.message,
    required this.timestamp,
  });

  // Convert Notification object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'content_id': contentId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a Notification object from a Map (from Firestore)
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      contentId: map['content_id'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
