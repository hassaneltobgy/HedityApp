import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_programming_project/home_page.dart';
import 'login_page.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'package:mobile_programming_project/Models/Firestore.dart'; // Import FirestoreService

class RegisterPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _notificationController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  final DatabaseClass mydb = DatabaseClass(); // Database instance
  final FirestoreService firestoreService = FirestoreService(); // Firestore service instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.9)),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[800],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(labelText: "Name", icon: Icons.person, controller: _nameController),
                        _buildTextField(labelText: "Email", icon: Icons.email, controller: _emailController),
                        _buildTextField(labelText: "Date of Birth", icon: Icons.cake, controller: _dobController),
                        _buildTextField(labelText: "Gender", icon: Icons.person_outline, controller: _genderController),
                        _buildTextField(labelText: "preferences", icon: Icons.favorite, controller: _preferencesController),
                        _buildTextField(
                            labelText: "Preferred Notification",
                            icon: Icons.notifications,
                            controller: _notificationController),
                        _buildTextField(labelText: "Phone Number ", icon: Icons.phone, controller: _phonenoController),
                        _buildTextField(
                          labelText: "Password",
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        _buildTextField(
                          labelText: "Confirm Password",
                          icon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Check if passwords match
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Passwords do not match!", style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Check if the phone number is valid (only digits)
                              String phoneNumber = _phonenoController.text;
                              if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please enter a valid phone number (digits only)", style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }


                              try {
                                // Firebase Authentication
                                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );

                                // Get the Firebase UID
                                String firebaseUid = userCredential.user!.uid;

                                // Save user info to Firestore using FirestoreService
                                Map<String, dynamic> userData = {
                                  'name': _nameController.text,
                                  'email': _emailController.text,
                                  'date_of_birth': _dobController.text,
                                  'gender': _genderController.text,
                                  'preferences': _preferencesController.text,
                                  'notification': _notificationController.text,
                                  'image_path': 'assets/Images/default_user_image.png',
                                  'PhoneNo':_phonenoController.text,

                                };
                                await firestoreService.addUser_Firestore(firebaseUid, userData);

                                // Optional: Save to SQLite if local storage is still needed
                                int userId = await mydb.insertUser(
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  _dobController.text,
                                  _genderController.text,
                                  _preferencesController.text,
                                  _notificationController.text,
                                  firebaseUid,
                                  _phonenoController.text,

                                );

                                // Navigate to HomePage with Firebase UID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage(userId: userId, firebaseUid: firebaseUid)),
                                );
                              } on FirebaseAuthException catch (e) {
                                String errorMessage;
                                if (e.code == 'email-already-in-use') {
                                  errorMessage = 'This email is already registered.';
                                } else if (e.code == 'weak-password') {
                                  errorMessage = 'The password is too weak.';
                                } else {
                                  errorMessage = 'An error occurred. Please try again.';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage, style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text("Register"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $labelText";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
