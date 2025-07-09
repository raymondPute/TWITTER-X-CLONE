import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twitter_x_clone/post_tweet.dart';
import 'GroupsPage Screen.dart';
import 'inbox_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'notifications_page.dart';

import 'package:intl/intl.dart';
import 'comment_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'assets/Xlogo.png',
            height: 40,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.grey[600],
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mail, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InboxPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // "For You" tab logic
                    },
                    child: Text(
                      'For You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                VerticalDivider(color: Colors.grey),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // "Following" tab logic
                    },
                    child: Text(
                      'Following',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200, // Set your preferred height
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('profiles')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Unknown User',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            '@unknown',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      );
                    }

                    var userData = snapshot.data!.data() as Map<String, dynamic>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[600],
                          backgroundImage: userData['profile_image_url'] != null
                              ? NetworkImage(userData['profile_image_url'])
                              : null,
                          child: userData['profile_image_url'] == null
                              ? const Icon(Icons.person, color: Colors.white, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '@${userData['username'] ?? 'No Username'}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${(userData['following'] as List?)?.length ?? 0} Following',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${(userData['followers'] as List?)?.length ?? 0} Followers',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () async {
                String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: currentUserId),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.white),
              title: Text('Premium', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: Colors.white),
              title: Text('Bookmarks', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.work, color: Colors.white),
              title: Text('Jobs', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.white),
              title: Text('Lists', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.mic, color: Colors.white),
              title: Text('Spaces', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Colors.white),
              title: Text('Monetization', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
              title: Text(
                'Log Out',
                style: Theme.of(context).textTheme.bodyLarge, // Update to bodyLarge
              ),
              onTap: () async {
                // Log the user out
                await FirebaseAuth.instance.signOut();

                // Navigate to the login screen after logging out
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),

          ],
        ),
      ),

      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tweets')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final tweets = snapshot.data?.docs ?? [];
              if (tweets.isEmpty) {
                return Center(
                  child: Text(
                    'No tweets available',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  final tweetData = tweets[index].data() as Map<String, dynamic>;
                  final tweetId = tweets[index].id;

                  final content = tweetData['content'] ?? 'No content';
                  final userName = tweetData['user_name'] ?? 'Unknown User';
                  final timestamp = tweetData['timestamp'];
                  final likes = tweetData['likes'] ?? 0;
                  final comments = tweetData['comments'] ?? 0;
                  final retweets = tweetData['retweets'] ?? 0;
                  final likedBy = List<String>.from(tweetData['likedBy'] ?? []);
                  final retweetedBy =
                  List<String>.from(tweetData['retweetedBy'] ?? []);

                  final formattedTimestamp = timestamp is Timestamp
                      ? DateFormat('MMMM dd, yyyy HH:mm a')
                      .format(timestamp.toDate())
                      : 'Unknown Date';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        content,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'By $userName at $formattedTimestamp',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  likedBy.contains(currentUserId) ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: likedBy.contains(currentUserId) ? Colors.red : Colors.grey,
                                ),
                                onPressed: () async {
                                  if (currentUserId != null) {
                                    final tweetRef = FirebaseFirestore.instance.collection('tweets').doc(tweetId);

                                    if (likedBy.contains(currentUserId)) {
                                      // Unlike
                                      await tweetRef.update({
                                        'likes': FieldValue.increment(-1),
                                        'likedBy': FieldValue.arrayRemove([currentUserId]),
                                      });
                                    } else {
                                      // Like
                                      await tweetRef.update({
                                        'likes': FieldValue.increment(1),
                                        'likedBy': FieldValue.arrayUnion([currentUserId]),
                                      });
                                    }
                                  }
                                },
                              ),
                              Text(
                                '$likes',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 16),
                              IconButton(
                                icon:
                                Icon(Icons.comment, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentPage(tweetId: tweetId),
                                    ),
                                  );
                                },
                              ),
                              Text(
                                '$comments',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  Icons.replay,
                                  color: retweetedBy.contains(currentUserId)
                                      ? Colors.green
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  if (currentUserId != null &&
                                      !retweetedBy.contains(currentUserId)) {
                                    FirebaseFirestore.instance
                                        .collection('tweets')
                                        .doc(tweetId)
                                        .update({
                                      'retweets': FieldValue.increment(1),
                                      'retweetedBy': FieldValue.arrayUnion(
                                          [currentUserId]),
                                    });
                                  }
                                },
                              ),
                              Text(
                                '$retweets',
                                style: TextStyle(color: Colors.white),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.share, color: Colors.white),
                                onPressed: () {
                                  Share.share(content);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isMenuOpen)
            Positioned(
              bottom: 80,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuItem(Icons.videocam, "Go Live", () {
                    // Handle Go Live action
                  }),
                  SizedBox(height: 10),
                  _buildMenuItem(Icons.chat, "Spaces", () {
                    // Handle Spaces action
                  }),
                  SizedBox(height: 10),
                  _buildMenuItem(Icons.photo, "Photos", () {
                    // Handle Photos action
                  }),
                  SizedBox(height: 10),
                  _buildMenuItem(Icons.create, "Post", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TweetCreatePage()),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: Colors.blue,
        child: Icon(_isMenuOpen ? Icons.close : Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
            // Stay on Home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TweetCreatePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(),
                ),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InboxPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}