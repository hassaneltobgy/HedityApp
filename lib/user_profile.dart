import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';  // Import image picker package
import 'dart:io';  // For handling picked images
import 'myPledgedGiftsPage.dart'; // Import My Pledged Gifts Page
import 'MyOwnGiftList.dart'; // Import GiftListPage (make sure this matches your file path)
import 'MyEventListPage.dart';
import 'package:mobile_programming_project/Models/Database.dart';

class ProfilePage extends StatefulWidget {

  final int userId;

  ProfilePage({required this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for personal information fields
  TextEditingController nameController = TextEditingController(text: 'John Doe');
  TextEditingController emailController = TextEditingController(text: 'johndoe@example.com');
  TextEditingController dobController = TextEditingController(text: '1990-01-01');
  TextEditingController genderController = TextEditingController(text: 'Male');
  TextEditingController nationalityController = TextEditingController(text: 'American');
  TextEditingController notificationController = TextEditingController(text: 'Email');
  final DatabaseClass mydb = DatabaseClass();// New Controller for Preferred Notification

  // Variable to store the profile picture
  File? _profileImage;

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    // Show options to choose from gallery or camera
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,  // You can also use ImageSource.camera to allow the user to take a picture
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);  // Update profile picture with the selected image
      });
    }
  }


  Future<void> _loadUserData() async {
    final userData = await mydb.getUserById(widget.userId);
    setState(() {
      nameController.text = userData['name'];
      emailController.text = userData['email'];
      dobController.text = userData['date_of_birth'] ?? '';
      genderController.text = userData['gender'] ?? '';
      nationalityController.text = userData['nationality'] ?? '';
      notificationController.text = userData['notification'] ?? '';
    });
  }
  @override
  void initState() {
    super.initState();
    _loadUserData();
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
                      onTap: _pickImage,  // Allow the user to tap the profile picture to change it
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage == null
                            ? AssetImage('assets/Images/John.jpg') // Default image if no profile picture
                            : FileImage(_profileImage!) as ImageProvider,  // Display the selected image
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
                            controller: nationalityController,
                            labelText: 'Nationality',
                          ),
                          _buildTextField(
                            controller: notificationController, // New TextField
                            labelText: 'Preferred Way of Notification',
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // UI updates automatically since the values in controllers are updated
                                  // No additional logic required here
                                });
                              },
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

                                    MaterialPageRoute(builder: (context) => MyEventListPage(userId:widget.userId)),
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
                        MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
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
          labelStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Bold and red label
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
