import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  File? _profileImage;
  bool isLoading = false;

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null) return;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics/${widget.userId}.jpg');
      await ref.putFile(_profileImage!);
      String url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profilePicUrl': url});
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    await _uploadProfilePicture();
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'bio': _bioController.text,
      'dob': _dobController.text,
    });
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
