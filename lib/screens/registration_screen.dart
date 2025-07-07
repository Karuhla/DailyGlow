import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void registerUser() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Registration successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CalendarScreen()),
      );
    } catch (e) {
      print('Registration error: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('Failed to register. Please try again.'),
        ),
      );
    }
  }

  Widget buildShadowInputField({
  required TextEditingController controller,
  required String hintText,
  bool obscureText = false,
}) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xFFE9EDF0),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.white,
          offset: Offset(-2, -2),
          blurRadius: 3,
        ),
        BoxShadow(
          color: Colors.grey,
          offset: Offset(2, 2),
          blurRadius: 3,
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: TextStyle(fontSize: 16),
    ),
  );
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EDF0),
        centerTitle: true,
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              buildShadowInputField(
                controller: usernameController,
                hintText: 'Username',
              ),
              const SizedBox(height: 16),

              buildShadowInputField(
                controller: emailController,
                hintText: 'Email',
              ),
              const SizedBox(height: 16),

              buildShadowInputField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: registerUser,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BC1FF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3.0,
                        offset: Offset(-2, -2),
                        color: Colors.white,
                      ),
                      BoxShadow(
                        blurRadius: 3.0,
                        offset: Offset(2, 2),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ),
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Color(0xFF7BC1FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
