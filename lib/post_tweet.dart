import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/tweet.dart';

class TweetCreatePage extends StatefulWidget {
  @override
  _TweetCreatePageState createState() => _TweetCreatePageState();
}

class _TweetCreatePageState extends State<TweetCreatePage> {
  final TextEditingController _tweetController = TextEditingController();
  final _uuid = Uuid(); // UUID for unique tweet IDs

  String _currentUserName = 'Unknown User';
  String _currentUserId = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Direct Firestore instance

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  // Fetch the current user's profile (name and ID) from Firestore
  Future<void> _getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await _firestore.collection('profiles').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _currentUserName = userData?['name'] ?? 'Unknown User';
          _currentUserId = userId;
        });
      }
    }
  }

  // Create a new tweet and save it to Firestore
  void _createTweet() async {
    final content = _tweetController.text.trim();
    if (content.isEmpty) return;

    if (_currentUserId.isEmpty) {
      print("User is not authenticated or profile not loaded");
      return;
    }

    final tweet = Tweet(
      id: _uuid.v4(),
      userId: _currentUserId,
      content: content,
      timestamp: Timestamp.fromDate(DateTime.now()), // Correct timestamp conversion
      userName: _currentUserName,
    );

    try {
      // Add tweet to Firestore collection
      await _firestore.collection('tweets').doc(tweet.id).set(tweet.toMap());
      Navigator.pop(context); // Go back after posting the tweet
    } catch (e) {
      print("Error creating tweet: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _createTweet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Post', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[600],
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tweetController,
                    maxLines: null,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "What's happening?",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }
}
