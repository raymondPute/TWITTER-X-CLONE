import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Register user function
  Future<void> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? '';
      if (userId.isNotEmpty) {
        await createUserDocument(userId);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  // Map Firebase error codes to user-friendly messages
  String getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return "The password is too weak.";
      case 'email-already-in-use':
        return "This email is already in use.";
      case 'invalid-email':
        return "The email address is not valid.";
      default:
        return "An error occurred. Please try again.";
    }
  }

  // Create the user document in Firestore
  Future<void> createUserDocument(String userId) async {
    try {
      await _firestore.collection('profiles').doc(userId).set({
        'id': userId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'date_of_birth': _dobController.text.trim(),
        'profile_image_url': '',
        'created_at': DateTime.now(),
        'followers': [],
        'following': [],
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error saving user data. Please try again.";
      });
    }
  }

  // Date Picker for Date of Birth
  Future<void> _selectDOB(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  // Register button click handler
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _dobController.text.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required.";
      });
      _isLoading = false;
      return;
    }

    await registerUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Xlogo.png', height: 100),
                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),

                _buildTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black,
                    border: const UnderlineInputBorder(),
                  ),
                  onTap: () => _selectDOB(context),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
