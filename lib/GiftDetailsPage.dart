import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gift; // Single gift object passed
  GiftDetailsPage({required this.gift}); // Constructor to receive gift details

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool isPledged = false;

  @override
  void initState() {
    super.initState();
    // Populate controllers with the gift data
    nameController.text = widget.gift['name'];
    descriptionController.text = widget.gift['description'];
    categoryController.text = widget.gift['category'];
    priceController.text = widget.gift['price'].toString();
    isPledged = widget.gift['status'] == 1; // Convert status to bool
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
                    child: Container(
                      width: 160,
                      height: 160,
                      child: Image.asset(
                        widget.gift['image'] ?? 'assets/Images/placeholder.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Read-Only Input Fields
                  _buildTextField(controller: nameController, labelText: 'Gift Name', readOnly: true),
                  _buildTextField(controller: descriptionController, labelText: 'Description', readOnly: true),
                  _buildTextField(controller: categoryController, labelText: 'Category', readOnly: true),
                  _buildTextField(controller: priceController, labelText: 'Price', readOnly: true),

                  SizedBox(height: 20),

                  // Status Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pledged Status:',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Switch(
                        value: isPledged,
                        onChanged: (value) {
                          setState(() {
                            isPledged = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        readOnly: readOnly,
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
