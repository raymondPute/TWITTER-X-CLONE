import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentPage extends StatefulWidget {
  final String tweetId;

  CommentPage({required this.tweetId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _addComment() async {
    final currentUser = _auth.currentUser;

    if (currentUser != null && _commentController.text.isNotEmpty) {
      // Add comment to Firestore
      await FirebaseFirestore.instance.collection('tweets').doc(widget.tweetId).update({
        'comments': FieldValue.increment(1),
      });

      await FirebaseFirestore.instance.collection('comments').add({
        'tweetId': widget.tweetId,
        'userId': currentUser.uid,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,  // Initialize with 0 likes
      });

      // Clear the text field
      _commentController.clear();
    }
  }

  // Function to toggle like on a comment
  void _toggleLike(String commentId, bool isLiked) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final commentRef = FirebaseFirestore.instance.collection('comments').doc(commentId);

      if (isLiked) {
        // Remove like
        await commentRef.update({
          'likes': FieldValue.increment(-1),
        });
      } else {
        // Add like
        await commentRef.update({
          'likes': FieldValue.increment(1),
        });
      }
    }
  }

  // Function to navigate to the reply screen
  void _replyToComment(String commentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReplyPage(commentId: commentId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Comments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('tweetId', isEqualTo: widget.tweetId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final comments = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentData = comments[index].data() as Map<String, dynamic>;
                      final commentText = commentData['comment'];
                      final userId = commentData['userId'];
                      final likes = commentData['likes'] ?? 0;
                      final commentId = comments[index].id;
                      final timestamp = commentData['timestamp']?.toDate() ?? DateTime.now();

                      // Fetch user info from 'profiles' collection
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('profiles').doc(userId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text(commentText),
                              subtitle: Text('Loading user info...'),
                            );
                          }

                          if (userSnapshot.hasError) {
                            return ListTile(
                              title: Text(commentText),
                              subtitle: Text('Error loading user info'),
                            );
                          }

                          // Check if user data is null before casting
                          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                          if (userData == null) {
                            return ListTile(
                              title: Text(commentText),
                              subtitle: Text('Unknown User commented'),
                            );
                          }
                          final name = userData['name'] ?? 'Unknown User';

                          // Format timestamp into a human-readable format
                          final timeAgo = _formatTimestamp(timestamp);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            timeAgo,
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        commentText,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              likes > 0 ? Icons.favorite : Icons.favorite_border,
                                              size: 20,
                                              color: likes > 0 ? Colors.red : Colors.grey,
                                            ),
                                            onPressed: () => _toggleLike(commentId, likes > 0),
                                          ),

                                          Text(
                                            '$likes Likes',
                                            style: TextStyle(fontSize: 14, color: Colors.blue),
                                          ),
                                          SizedBox(width: 15),
                                          IconButton(
                                            icon: Icon(Icons.comment, size: 20, color: Colors.grey),
                                            onPressed: () => _replyToComment(commentId),
                                          ),
                                          Text(
                                            'Reply',
                                            style: TextStyle(fontSize: 14, color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format timestamp into a readable format (e.g., 5 minutes ago)
  String _formatTimestamp(DateTime timestamp) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}

class ReplyPage extends StatelessWidget {
  final String commentId;

  ReplyPage({required this.commentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply to Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Add reply functionality here (TextField for reply input)
            TextField(
              decoration: InputDecoration(hintText: 'Write your reply...'),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Add reply to Firestore
              },
            ),
          ],
        ),
      ),
    );
  }
}
