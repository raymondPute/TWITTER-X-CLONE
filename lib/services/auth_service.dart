import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Function to create a user document in Firestore
  Future<void> createUserDocument() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          await userDocRef.set({
            'name': 'Default Name',
            'email': user.email,
            'profilePicUrl': '',
            'joinedDate': DateTime.now().toString(),
            'dob': '01/01/1990',
            'followers': 0,
            'following': 0,
          });
          print('User document created for $userId');
        } else {
          print('User document already exists');
        }
      }
    } catch (e) {
      print("Error creating user document: $e");
    }
  }
}
