import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'myPledgedGiftsPage.dart';
import 'MyEventListPage.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String firebaseUid;

  ProfilePage({required this.userId, required this.firebaseUid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for personal information fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController preferencesController = TextEditingController();
  TextEditingController notificationController = TextEditingController();
  TextEditingController imageController=TextEditingController();
  final DatabaseClass mydb = DatabaseClass();


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await mydb.getUserById(widget.userId);
    setState(() {
      nameController.text = userData['name'] ?? '';
      emailController.text = userData['email'] ?? '';
      dobController.text = userData['date_of_birth'] ?? '';
      genderController.text = userData['gender'] ?? '';
      preferencesController.text = userData['preferences'] ?? '';
      notificationController.text = userData['notification'] ?? '';
      imageController.text = userData['image_path'] ?? 'assets/Images/John.jpg';
    });
  }

  Future<void> _updateProfileImage(String newPath) async {
    setState(() {
      imageController.text = newPath;
      print(imageController.text);
    });
    await mydb.updateUserImage(widget.userId, newPath); // Update SQLite database
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.firebaseUid)
        .update({'image_path': newPath}); // Update Firestore
  }

  Future<void> _updateUserInfo() async {

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (emailController.text.isEmpty || !emailRegExp.hasMatch(emailController.text)) {
      // If email is empty or doesn't match the pattern, show a validation snackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Make Sure Email is in Correct Format example: hassan@gmail.com',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red, // Red background for the SnackBar
          duration: Duration(seconds: 6), // Set duration to make it visible for 3 seconds
          behavior: SnackBarBehavior.floating, // Optional: makes the SnackBar float above content
          action: SnackBarAction(
            label: 'Okay',
            onPressed: () {
              // You can add an action, for example, closing the SnackBar
            },
            textColor: Colors.white, // Action text color
          ),
        ),
      );
      return; // Exit the function if email is not valid
    }
    if (dobController.text.isEmpty || !dateRegExp.hasMatch(dobController.text)) {
      // If date is empty or doesn't match the yyyy-mm-dd pattern
      //''
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid date in the format yyyy-mm-dd.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red, // Red background for the SnackBar
          duration: Duration(seconds: 6), // Set duration to make it visible for 3 seconds
          behavior: SnackBarBehavior.floating, // Optional: makes the SnackBar float above content
          action: SnackBarAction(
            label: 'Okay',
            onPressed: () {
              // You can add an action, for example, closing the SnackBar
            },
            textColor: Colors.white, // Action text color
          ),
        ),
      );
      return; // Exit the function if date is not valid
    }
    final updatedData = {
      'name': nameController.text,
      'email': emailController.text,
      'date_of_birth': dobController.text,
      'gender': genderController.text,
      'preferences': preferencesController.text,
      'notification': notificationController.text,
      'image_path':imageController.text,
    };

    await mydb.updateUser(userId:widget.userId,name: nameController.text,
      email: emailController.text,
        dateOfBirth: dobController.text,
      gender: genderController.text,
        preferences: preferencesController.text,
      notification: notificationController.text,imagePath:imageController.text ); // Update SQLite database
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.firebaseUid)
        .update(updatedData); // Update Firestore

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User information updated successfully!')),
    );
  }

  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Profile Picture', style: TextStyle(color: Colors.red)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildImageOption('assets/Images/John.jpg'),
                _buildImageOption('assets/Images/Jane.jpg'),
                _buildImageOption('assets/Images/alice.jpg'),
                _buildImageOption('assets/Images/male.png'),
                _buildImageOption('assets/Images/female.png'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageOption(String imagePath) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
      title: Text(imagePath.split('/').last),
      onTap: () {
        _updateProfileImage(imagePath);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile Page',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/background.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Profile Picture Section
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSelectionDialog, // Open image selection dialog
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(imageController.text),
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // User Information Section
                  Card(
                    color: Colors.black.withOpacity(0.6),
                    margin: EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Personal Information',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: nameController,
                            labelText: 'Name',
                          ),
                          _buildTextField(
                            controller: emailController,
                            labelText: 'Email',
                          ),
                          _buildTextField(
                            controller: dobController,
                            labelText: 'Date of Birth',
                          ),
                          _buildTextField(
                            controller: genderController,
                            labelText: 'Gender',
                          ),
                          _buildTextField(
                            controller: preferencesController,
                            labelText: 'Prefrences',
                          ),
                          _buildTextField(
                            controller: notificationController,
                            labelText: 'Preferred Way of Notification',
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _updateUserInfo, // Update user info
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Update Information',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                  // User's Created Events Section
                  Card(
                    color: Colors.black.withOpacity(0.6),
                    margin: EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1, // Replace with the actual number of events
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title:  Text(
                                  'My Created Events',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),

                                trailing: Icon(Icons.arrow_forward, color: Colors.white),
                                onTap: () {
                                  // Navigate to GiftListPage when an event is tapped
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(builder: (context) => MyEventListPage(userId:widget.userId,firebaseUid: widget.firebaseUid,)),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Link to My Pledged Gifts Page
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PledgedGiftsPage(firebaseUid: widget.firebaseUid)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'View My Pledged Gifts',
                      style: GoogleFonts.poppins(fontSize: 14),
                     ),
                     ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.black.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
