import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      print('Fetching profile for userId: ${widget.userId}');
      // Query Firestore for the user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('profiles') // Ensure this matches your Firestore collection name
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        print('User document does not exist for userId: ${widget.userId}');
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(dynamic date) {
    if (date is String) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        return formatter.format(parsedDate);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (date is Timestamp) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date.toDate());
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userData?['profile_image_url']?.isNotEmpty == true
                        ? NetworkImage(userData!['profile_image_url'])
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(userId: widget.userId),
                        ),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userData?['name'] ?? 'No Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@${userData?['username'] ?? 'No Username'}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.cake, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Born ${userData?['date_of_birth'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Joined ${formatDate(userData?['created_at'])}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${(userData?['following'] as List?)?.length ?? 0} Following',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(userData?['followers'] as List?)?.length ?? 0} Followers',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
