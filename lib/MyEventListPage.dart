import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_programming_project/MyOwnGiftList.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'user_profile.dart';

class MyEventListPage extends StatefulWidget {

  final int userId;
  final String firebaseUid;

  MyEventListPage({required this.userId,required this.firebaseUid});

  @override
  _MyEventListPageState createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  final db = DatabaseClass();
  List<Map<String, dynamic>> events = [];
  String? _sortBy = 'name'; // Default sorting by name

  // Firestore reference
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId, firebaseUid: widget.firebaseUid),
      ),
    );
  }

  void _addEvent() {

    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final statusController = TextEditingController();
    final dateController = TextEditingController();
    final descriptionController=TextEditingController();
    final locationController =TextEditingController();


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: Key('MyEventName'),
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  key: Key('MyCategory'),
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  key: Key('MyDescription'),
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  key: Key('MyDate'),
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  key: Key('MyLocation'),
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String category = categoryController.text;
                String status = statusController.text;
                String date = dateController.text;
                String description = descriptionController.text;
                String location = locationController.text;

                // Check if name is valid (text only)
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
                  // If name contains non-text characters
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name should only contain letters and spaces')),
                  );
                  return;
                }

                // Check if date is in the correct format (yyyy-MM-dd)
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
                  // If date format is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Date should be in the format yyyy-MM-dd')),
                  );
                  return;
                }

                // Parse the date and compare with today's date
                DateTime enteredDate = DateTime.parse(date);
                DateTime today = DateTime.now();
                if (enteredDate.isAtSameMomentAs(today)) {
                  status = 'Current';
                } else if (enteredDate.isAfter(today)) {
                  status = 'Upcoming';
                } else {
                  status = 'Past';
                }

                // Check if all fields are filled
                if (name.isNotEmpty && category.isNotEmpty && status.isNotEmpty &&
                    date.isNotEmpty && description.isNotEmpty && location.isNotEmpty) {

                  // Add to Firestore first

                  String firebaseUid = await _addEventToFirestore(
                    name, category, status, date,description,location
                  );

                  await _addEventToDatabase(
                    name, firebaseUid, category, status, date,location,description
                  );

                  // Close the dialog

                  Navigator.pop(context);
                } else {
                  // Show error if any required field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all the fields')),
                  );
                }
              },
              child: Text('Add Event'),
            ),
          ],
        );
      },
    );
  }


  Future<String> _addEventToFirestore(String name, String category, String status, String date,String description,String location) async {
    DocumentReference docRef = await eventsCollection.add({
      'name': name,
      'category': category,
      'status': status,
      'date': date,
      'description':description,
      'location':location,
      'userUid': widget.firebaseUid, // Store the Firebase UID as reference
    });
    return docRef.id; // Return the document ID
  }


  void _editEvent(int index) {
    final nameController = TextEditingController(text: events[index]['name']);
    final categoryController = TextEditingController(text: events[index]['category']);
    final statusController = TextEditingController(text: events[index]['status']);
    final dateController = TextEditingController(text: events[index]['date']);
    final descriptionController=TextEditingController(text: events[index]['description']);
    final locationController =TextEditingController(text: events[index]['location']);
    int eventId = events[index]['ID'];
    String eventfirebaseId=events[index]['firebaseUid'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                String category = categoryController.text;
                String status = statusController.text;
                String date = dateController.text;
                String description = descriptionController.text;
                String location = locationController.text;

                // Check if name is valid (text only)
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
                  // If name contains non-text characters
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name should only contain letters and spaces')),
                  );
                  return;
                }

                // Check if date is in the correct format (yyyy-MM-dd)
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
                  // If date format is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Date should be in the format yyyy-MM-dd')),
                  );
                  return;
                }

                // Parse the date and compare with today's date
                DateTime enteredDate = DateTime.parse(date);
                DateTime today = DateTime.now();
                if (enteredDate.isAtSameMomentAs(today)) {
                  status = 'Current';
                } else if (enteredDate.isAfter(today)) {
                  status = 'Upcoming';
                } else {
                  status = 'Past';
                }

                // Check if all fields are filled
                if (name.isNotEmpty && category.isNotEmpty && status.isNotEmpty &&
                    date.isNotEmpty && description.isNotEmpty && location.isNotEmpty) {

                  // Add to Firestore first

                  print('$eventId');

                  await db.updateEvent(
                    eventId,
                    name,
                    category,
                    location,
                    status,
                      date,
                      description,
                  );
                  // Update Firestore
                  await _updateEventInFirestore(eventfirebaseId, name, category, location ,status,date,description);
                  Navigator.pop(context);
                  await _loadEvents();
                } else {
                  // Show error if any required field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all the fields')),
                  );
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEventInFirestore(
      String eventfirebaseId, String name, String category,String location, String status, String date,String description) async {
    // Directly reference the document with the given eventfirebaseId
    DocumentReference docRef = eventsCollection.doc(eventfirebaseId);

    try {
      // Update the specified fields in the document
      await docRef.update({
        'name': name,
        'category': category,
        'location':location,
        'status':status,
        'date': date,
        'description':description,
      });
      print('Event updated successfully in Firestore.');
    } catch (e) {
      print('Error updating event in Firestore: $e');
    }
  }


  Future<void> _deleteEvent(int index) async {
    int eventId = events[index]['ID'];
    String eventfirebaseId=events[index]['firebaseUid'];
    await _deleteEventFromDatabase(eventId);
    await _deleteEventFromFirestore(eventfirebaseId);
  }

  Future<void> _deleteEventFromFirestore(String eventfirebaseId) async {
    DocumentReference docRef = eventsCollection.doc(eventfirebaseId);
    docRef.delete();
  }

  void _goToGiftListPage(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyOwnGiftListPage(event),
      ),
    );
  }

  void _sortEvents(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'name') {
        events.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (criteria == 'category') {
        events.sort((a, b) => a['category']!.compareTo(b['category']!));
      } else if (criteria == 'status') {
        events.sort((a, b) => a['status']!.compareTo(b['status']!));
      } else if (criteria == 'date') {
        events.sort((a, b) => a['date']!.compareTo(b['date']!));
      }
    });
  }

  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> userEvents = await db.getEventsForUser(widget.userId);
    setState(() {
      events = userEvents;
    });

    // Optionally load events from Firestore as well and sync with local DB if necessary

  }

  /*                String name = nameController.text;
                String category = categoryController.text;
                String status = statusController.text;
                String date = dateController.text;
                String description = descriptionController.text;
                String location = locationController.text;_*/

  Future<void> _addEventToDatabase(String name,String firebaseUid, String category, String status, String date,String location,String description) async {
    await db.insertEvent(name, firebaseUid, category, status, date, location,description,widget.userId);
    await _loadEvents(); // Refresh events after adding
  }

  Future<void> _deleteEventFromDatabase(int eventId) async {
    // Delete the event from local database
    await db.deleteEvent(eventId);
    await _loadEvents();
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Event List',
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: _goToProfile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.account_circle_sharp, color: Colors.red),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
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
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by:',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      dropdownColor: Colors.black,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _sortEvents(newValue);
                        }
                      },
                      items: <String>['name', 'category', 'status', 'date']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: Text(
                    'Add New Event',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        key: Key('event_$index'),
                        onTap: () {
                          _goToGiftListPage(event);
                        },
                        child: Card(

                          color: Colors.black.withOpacity(0.6),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              event['name'],
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            subtitle: Text(
                              'Category: ${event['category']} - Status: ${event['status']} - Date: ${event['date']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _editEvent(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _deleteEvent(index),
                                ),
                              ],
                            ),
                          ),
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
