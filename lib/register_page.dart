import 'package:flutter/material.dart';
import 'package:mobile_programming_project/home_page.dart'; // Replace with your HomePage import
import 'login_page.dart'; // Import LoginPage
import 'package:mobile_programming_project/Models/Database.dart'; // Import the DatabaseClass

class RegisterPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _notificationController = TextEditingController();
  final DatabaseClass mydb = DatabaseClass(); // Database instance

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
                        _buildTextField(labelText: "Nationality", icon: Icons.flag, controller: _nationalityController),
                        _buildTextField(
                            labelText: "Preferred Notification", icon: Icons.notifications, controller: _notificationController),
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
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Passwords do not match!", style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Save user to the database
                              int userId = await mydb.insertUser(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _dobController.text,
                                _genderController.text,
                                _nationalityController.text,
                                _notificationController.text,
                              );

                              // Navigate to HomePage
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
                              );
                            }
                          },
                          child: Text("Register"),
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
