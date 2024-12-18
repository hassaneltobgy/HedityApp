import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'MyOwnGiftDetailsPage.dart';

class MyOwnGiftListPage extends StatefulWidget {
  final Map<String, dynamic> event;

  MyOwnGiftListPage(this.event);

  @override
  _MyOwnGiftListPageState createState() => _MyOwnGiftListPageState();
}

class _MyOwnGiftListPageState extends State<MyOwnGiftListPage> {
  List<Map<String, dynamic>> gifts = [];
  String? _sortBy = 'name';
  final DatabaseClass db = DatabaseClass();
  String? _selectedImagePath;
  final List<Map<String, String>> availableImages = [
    {'name': 'Headphone', 'path': 'assets/Images/headphones.jpg'},
    {'name': 'SmartWatch', 'path': 'assets/Images/smartwatch.jpg'},
    {'name': 'Necklace', 'path': 'assets/Images/necklace.jpeg'},
    {'name': 'Kindle', 'path': 'assets/Images/kindle.jpg'},
    {'name': 'Gaming Mouse', 'path': 'assets/Images/gamingmouse.jpg'},
    {'name': 'Boxing Gloves', 'path': 'assets/Images/boxinggloves.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    List<Map<String, dynamic>> eventGifts = await db.getGiftsForEvent(widget.event['ID']);
    setState(() {
      gifts = eventGifts;
    });
  }




  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select an Image'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableImages.map((image) {
                      return ListTile(
                        leading: Image.asset(image['path']!, width: 40, height: 40),
                        title: Text(image['name']!),
                        onTap: () {
                          // Update the _selectedImagePath in the parent widget
                          setState(() {
                            _selectedImagePath = image['path']; // This will trigger the parent widget to rebuild
                          });

                          Navigator.pop(context); // Close the dialog after selection
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Add a new gift
  void _addGift() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Gift'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Gift Name')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                ElevatedButton(
                  onPressed: () {
                    _showImageSelectionDialog();
                  },
                  child: Text('Choose an Image'),
                ),
// Display the selected image if any

              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    _selectedImagePath != null) {
                  print('Selected Image Path: $_selectedImagePath');
                  // Check for null here
                  //String name, String description, String category, double price,
                  // String imagePath, String eventId, int is_pledged

                  await db.insertGift(
                      nameController.text,
                      descriptionController.text,
                      categoryController.text,
                      double.tryParse(priceController.text) ?? 0,
                      _selectedImagePath!, // Now we are sure _selectedImagePath is not null
                      widget.event['ID'],
                      0
                  );
                  await _loadGifts(); // Refresh gift list
                  Navigator.pop(context);
                }

              },
              child: Text('Add Gift'),
            ),
          ],
        );
      },
    );
  }

  // Edit an existing gift
  void _editGift(Map<String, dynamic> gift) {

    // Check if the gift is available for editing (status == 0)
    //if status !=0 means gift is either pledged or  purchased
    if (gift['status'] != 0) {
      // Show a message to the user that the gift is either pledged or purchased
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This gift cannot be edited because it is pledged or purchased.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the function if the gift is not available for editing
    }

    final nameController = TextEditingController(text: gift['name']);
    final descriptionController = TextEditingController(text: gift['description']);
    final categoryController = TextEditingController(text: gift['category']);
    final priceController = TextEditingController(text: gift['price'].toString());

    // Set the current image for the gift
    _selectedImagePath = gift['image_path'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Gift Name')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                ElevatedButton(
                  onPressed: () {
                    _showImageSelectionDialog();
                  },
                  child: Text('Choose an Image'),
                ),
                // Display the selected image if any
                if (_selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(_selectedImagePath!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  await db.updateGift(
                    gift['ID'], // Use the ID to identify the gift in the database
                    nameController.text,
                    descriptionController.text,
                    categoryController.text,
                    double.tryParse(priceController.text) ?? 0,
                    _selectedImagePath!, // Update the image path
                  );
                  await _loadGifts(); // Reload the gift list to reflect changes
                  Navigator.pop(context);
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );

      },
    );
  }

  void _deleteGift(int giftId) async {
  int status=await db.getGiftStatus(giftId);
    if (status != 0) {
      // Show a message to the user that the gift is either pledged or purchased
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This gift cannot be deleted because it is pledged or purchased.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the function if the gift is not available for editing
    }
    await db.deleteGift(giftId);
    await _loadGifts(); // Refresh after deletion
  }

  // Firestore commit logic
  Future<void> _commitGiftsToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final eventId = widget.event['ID']; //local Gift Id
    String? firebaseEventUid = await db.getEventFirebaseUid(eventId);


    try {

      if (firebaseEventUid != null){
        print('Firebase Event UID: $firebaseEventUid');
        // 1. Delete all existing gifts for this event from Firestore
      QuerySnapshot snapshot = await firestore
          .collection('gifts')
          .where('event_id', isEqualTo: firebaseEventUid)
          .get();

      for (var doc in snapshot.docs) {
        int status = doc['status'];
        if (status == 0) {
          await firestore.collection('gifts').doc(doc.id).delete();
        }

      }
      }

      // 2. Insert gifts from the local database into Firestore
      final localGifts = await db.getGiftsForEvent(eventId);
      for (var gift in localGifts) {
        // Add the gift to Firestore
        /*
        * 'name': name,
        'description': description,
        'category': category,
        'price': price,
        'image_path': imagePath,  // Save the image path
        'event_id': eventId,
        'status':is_pledged,*/
        int status = gift['status'];
        if(status==0) {
          DocumentReference docRef = await firestore.collection('gifts').add({
            'name': gift['name'],
            'description': gift['description'],
            'category': gift['category'],
            'price': gift['price'],
            'image_path': gift['image_path'],
            'event_id': firebaseEventUid,
            'status': gift['status'],
          });

          // Update firebaseUid in the local database
          await db.updateGiftFirebaseUid(gift['ID'], docRef.id);
        }
      }

      // Reload gifts to reflect the updated firebaseUid
      await _loadGifts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gifts successfully committed to Firestore")),
      );
    } catch (e) {
      print("Error committing gifts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to commit gifts. Please try again.")),
      );
    }
  }

  void _navigateToGiftDetails(Map<String, dynamic> gift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => myOwnGiftDetailsPage(gift),
      ),
    ).then((_) => _loadGifts());
  }

  // Add a commit button to the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gifts for ${widget.event['name']}',
          style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by:',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      dropdownColor: Colors.black,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                            gifts.sort((a, b) => a[newValue].compareTo(b[newValue]));
                          });
                        }
                      },
                      items: ['name', 'category'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addGift,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: Text('Add New Gift'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _commitGiftsToFirestore,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: Text('Commit to Firestore'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];

                      return ListTile(
                        leading: gift['image_path'] != null
                            ? Image.asset(gift['image_path'], width: 50, height: 50)
                            : Icon(Icons.image, size: 50, color: Colors.grey),
                        title: Text(gift['name'], style: TextStyle(color: Colors.white)),
                        subtitle: Text('${gift['category']} - \$${gift['price']}', style: TextStyle(color: Colors.grey)),
                        onTap: () => _navigateToGiftDetails(gift),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _editGift(gift),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteGift(gift['ID']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
