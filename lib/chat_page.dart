import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  ChatPage({required this.receiverId, required this.receiverName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message to Firestore
  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = {
      'content': content,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Send message to Firestore (sender's side)
      await _firestore
          .collection('messages')
          .doc('${currentUserId}_${widget.receiverId}')
          .collection('chat')
          .add(message);

      // Send message to receiver's Firestore (receiver's side)
      await _firestore
          .collection('messages')
          .doc('${widget.receiverId}_${currentUserId}')
          .collection('chat')
          .add(message);

      _messageController.clear();  // Clear message input after sending
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Format timestamp into a readable string
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime); // Format time as hh:mm AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverName}', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc('${currentUserId}_${widget.receiverId}')
                  .collection('chat')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'];
                    final timestamp = messageData['timestamp'] as Timestamp;

                    // Define if the message is sent by the current user
                    bool isSentByCurrentUser = senderId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Align(
                        alignment: isSentByCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          constraints: BoxConstraints(maxWidth: 250),
                          child: Column(
                            crossAxisAlignment: isSentByCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageData['content'],
                                style: TextStyle(
                                  color: isSentByCurrentUser ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: isSentByCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isSentByCurrentUser)
                                  // Removed the CircleAvatar displaying the receiver's image
                                    Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  SizedBox(width: 5),
                                  Text(
                                    isSentByCurrentUser ? 'You' : widget.receiverName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.black), // Ensure the input text is visible
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
