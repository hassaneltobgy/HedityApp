import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:mobile_programming_project/home_page.dart'; // Import HomePage
import 'register_page.dart'; // Import RegisterPage
import 'package:mobile_programming_project/Models/Database.dart'; // Import DatabaseClass

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseClass mydb = DatabaseClass();

  bool _isLoading = false; // For loading indicator

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
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _handleLogin,
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Get the Firebase UID
        String firebaseUid = userCredential.user!.uid;

        // Retrieve the corresponding userId from the local database
        int? userId = await mydb.getUserIdByFirebaseUid(firebaseUid);

        if (userId == null) {
          // Fetch data from Firestore and sync it locally
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUid)
              .get();

          if (!userDoc.exists) {
            throw Exception('User data not found in Firestore');
          }

          // Sync user data
          final userData = userDoc.data()!;

// Add image_path to SQLite database entry
          await mydb.insertUser(
            userData['name'] ?? '',
            userData['email'] ?? '',
            '', // Password isn't typically stored locally for security
            userData['date_of_birth'] ?? '',
            userData['gender'] ?? '',
            userData['nationality'] ?? '',
            userData['notification'] ?? 'enabled',
            firebaseUid,
            userData['PhoneNo'] ?? '',
          );


          // Sync events and gifts
          await _syncUserEventsAndGifts(firebaseUid);

          // Fetch the new userId from the local database
          userId = await mydb.getUserIdByFirebaseUid(firebaseUid);
        }

        // Navigate to HomePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userId!,firebaseUid:firebaseUid),
          ),
        );
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _syncUserEventsAndGifts(String firebaseUid) async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userUid', isEqualTo: firebaseUid) // Filter for logged-in user
          .get();


      for (var eventDoc in eventsSnapshot.docs) {
        final FirebaseeventId = eventDoc.id;
        final eventData = eventDoc.data();
//  Future<void> insertEvent(String name,String Firebaseuid, String category, String status,
//  String date,String location,String description, int userId)
        await mydb.insertEvent(
          eventData['name'] ?? '',
          FirebaseeventId,
          eventData['category'] ?? '',
          eventData['status'] ?? '',
          eventData['date'] ?? '',
          eventData['location'] ?? '',
          eventData['description'] ?? '',
          (await mydb.getUserIdByFirebaseUid(firebaseUid))!,
        );

        //function to get local ID for event using FirebaseeventId then put in
        //a variable to be used in gifts
       int? localeventid= await mydb.getEventIdByFirebaseUid(FirebaseeventId);


        final giftsSnapshot = await FirebaseFirestore.instance
            .collection('gifts')
            .where('event_id', isEqualTo: FirebaseeventId) // Filter for logged-in user
            .get();


        for (var giftDoc in giftsSnapshot.docs) {
          final giftData = giftDoc.data();
          await mydb.insertGift(
            giftData['name'] ?? '',
            giftData['description'] ?? '',
            giftData['category'] ?? '',
            giftData['price']?.toDouble() ?? 0.0,
            giftData['image_path'] ?? '',
            localeventid!, // Assuming eventId can be converted to int
            giftData['status'] ,
          );
        }
      }
    } catch (e) {
      print('Error syncing events and gifts: $e');
      throw Exception('Failed to sync events and gifts');
    }
  }
}
