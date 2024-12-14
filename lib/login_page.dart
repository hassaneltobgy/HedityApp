import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:mobile_programming_project/home_page.dart'; // Import HomePage
import 'register_page.dart'; // Import RegisterPage
import 'package:mobile_programming_project/Models/Database.dart'; // Import DatabaseClass

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseClass mydb = DatabaseClass(); // Database instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Black overlay for opacity
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          // Login Form Container
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
                child: Container(
                  width: double.infinity,
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
                          "Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          labelText: "Email",
                          icon: Icons.email,
                          controller: _emailController,
                        ),
                        _buildTextField(
                          labelText: "Password",
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Firebase Authentication
                                UserCredential userCredential =
                                await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );

                                // Get the Firebase UID
                                String firebaseUid = userCredential.user!.uid;

                                // Retrieve the corresponding userId from the local database
                                int? userId = await mydb.getUserIdByFirebaseUid(firebaseUid);
                                print('UserId from local database: $userId');

                                if (userId != null) {
                                  // If userId exists in the local database, navigate to HomePage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(userId: userId),
                                    ),
                                  );
                                } else {
                                  // Handle error: No matching userId found
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('User not found in local database')),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {

                                  print('Error Code: ${e.code}');
                                print('Error Message: ${e.message}');
                                print("I am currently at exception");
                                // Handle Firebase authentication errors
                                String errorMessage;
                                if (e.code == 'user-not-found') {
                                  errorMessage = 'No user found for that email.';
                                } else if (e.code == 'wrong-password') {
                                  errorMessage = 'Wrong password provided for that user.';
                                } else {
                                  errorMessage = 'An error occurred. Please try again.';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              }
                            }
                          },
                          child: Text("Login"),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
