import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Follow/Unfollow logic
  Future<void> _toggleFollow(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return; // Ensure user is logged in

    final currentUserDoc =
    FirebaseFirestore.instance.collection('profiles').doc(currentUserId);
    final targetUserDoc =
    FirebaseFirestore.instance.collection('profiles').doc(targetUserId);

    final currentUserData = await currentUserDoc.get();
    final targetUserData = await targetUserDoc.get();

    if (!currentUserData.exists || !targetUserData.exists) return;

    final currentUserFollowing =
    List<String>.from(currentUserData.data()?['following'] ?? []);
    final targetUserFollowers =
    List<String>.from(targetUserData.data()?['followers'] ?? []);

    if (currentUserFollowing.contains(targetUserId)) {
      // Unfollow
      currentUserFollowing.remove(targetUserId);
      targetUserFollowers.remove(currentUserId);
    } else {
      // Follow
      currentUserFollowing.add(targetUserId);
      targetUserFollowers.add(currentUserId);
    }

    await currentUserDoc.update({'following': currentUserFollowing});
    await targetUserDoc.update({'followers': targetUserFollowers});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for users',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profiles')
                    .where('name', isGreaterThanOrEqualTo: _searchQuery)
                    .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final profiles = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profileData =
                      profiles[index].data() as Map<String, dynamic>;
                      final userId = profileData['id'];
                      final userName = profileData['name'];
                      final profileImageUrl =
                          profileData['profile_image_url'] ??
                              'https://via.placeholder.com/150';
                      final followers =
                      List<String>.from(profileData['followers'] ?? []);
                      final isFollowing = followers.contains(
                          FirebaseAuth.instance.currentUser?.uid);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                        title: Text(
                          userName ?? 'Unknown User',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle:
                        Text('@$userId', style: TextStyle(color: Colors.grey)),
                        trailing: ElevatedButton(
                          onPressed: () => _toggleFollow(userId),
                          child: Text(
                            isFollowing ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isFollowing ? Colors.red : Colors.blue,
                            minimumSize: Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
