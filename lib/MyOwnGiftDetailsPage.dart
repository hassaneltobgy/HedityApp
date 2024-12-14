import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image picker functionality
import 'dart:io'; // Import dart:io for File class
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_programming_project/Models/Database.dart';

class myOwnGiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gift;

  myOwnGiftDetailsPage(this.gift);

  @override
  _myOwnGiftDetailsPageState createState() => _myOwnGiftDetailsPageState();
}

class _myOwnGiftDetailsPageState extends State<myOwnGiftDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController(); // For image path
  final DatabaseClass db = DatabaseClass();

  XFile? _imageFile; // For user-picked image
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with gift data, making sure image is a valid string
    nameController.text = widget.gift['name'] ?? '';
    descriptionController.text = widget.gift['description'] ?? '';
    categoryController.text = widget.gift['category'] ?? '';
    priceController.text = widget.gift['price']?.toString() ?? '';
    imageController.text = widget.gift['image_path'] ?? ''; // Ensure it's not null
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Simply go back without updating gift
          },
        ),
        title: Text(
          'Gift Details',
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
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gift Image Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: ClipOval(
                        child: Container(
                          width: 160, // Diameter of the circle
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: _imageFile != null
                                  ? FileImage(File(_imageFile!.path))
                                  : (imageController.text.isNotEmpty
                                  ? AssetImage(imageController.text)
                                  : AssetImage('assets/Images/default.png'))
                              as ImageProvider,
                              fit: BoxFit.contain, // Ensures the entire image fits inside the circle
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Input Fields
                  _buildReadOnlyTextField(controller: nameController, labelText: 'Gift Name'),
                  _buildReadOnlyTextField(controller: descriptionController, labelText: 'Description'),
                  _buildReadOnlyTextField(controller: categoryController, labelText: 'Category'),
                  _buildReadOnlyTextField(controller: priceController, labelText: 'Price'),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create read-only text fields
  Widget _buildReadOnlyTextField({required TextEditingController controller, required String labelText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        enabled: false, // Make the text field read-only
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
