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
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
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
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    statusController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  // Add event to local database
                  await _addEventToDatabase(
                    nameController.text,
                    categoryController.text,
                    statusController.text,
                    dateController.text,
                  );
                  // Add event to Firestore
                  await _addEventToFirestore(
                    nameController.text,
                    categoryController.text,
                    statusController.text,
                    dateController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addEventToFirestore(String name, String category, String status, String date) async {
    await eventsCollection.add({
      'name': name,
      'category': category,
      'status': status,
      'date': date,
      'userUid': widget.firebaseUid, // Store the Firebase UID as reference
    });
  }

  void _editEvent(int index) {
    final nameController = TextEditingController(text: events[index]['name']);
    final categoryController = TextEditingController(text: events[index]['location']);
    final statusController = TextEditingController(text: events[index]['description']);
    final dateController = TextEditingController(text: events[index]['date']);
    int eventId = events[index]['ID'];

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
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
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
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    statusController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  // Update local database
                  await db.updateEvent(
                    eventId,
                    nameController.text,
                    categoryController.text,
                    statusController.text,
                    dateController.text,
                  );
                  // Update Firestore
                  await _updateEventInFirestore(eventId, nameController.text, categoryController.text, statusController.text, dateController.text);
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

  Future<void> _updateEventInFirestore(int eventId, String name, String category, String status, String date) async {
    QuerySnapshot snapshot = await eventsCollection.where('eventId', isEqualTo: eventId).get();
    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = snapshot.docs[0];
      doc.reference.update({
        'name': name,
        'category': category,
        'status': status,
        'date': date,
      });
    }
  }

  Future<void> _deleteEvent(int index) async {
    int eventId = events[index]['ID'];
    await _deleteEventFromDatabase(eventId);
    await _deleteEventFromFirestore(eventId);
  }

  Future<void> _deleteEventFromFirestore(int eventId) async {
    QuerySnapshot snapshot = await eventsCollection.where('eventId', isEqualTo: eventId).get();
    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = snapshot.docs[0];
      doc.reference.delete();
    }
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

  Future<void> _loadEventsFromFirestore() async {
    QuerySnapshot snapshot = await eventsCollection.where('userUid', isEqualTo: widget.firebaseUid).get();
    for (var doc in snapshot.docs) {
      // Add each Firestore event to the local DB if it's not already there
      Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
      await db.insertEvent(event['name'], event['category'], event['status'], event['date'], widget.userId);
    }
    await _loadEvents(); // Refresh the local events list after syncing with Firestore
  }

  Future<void> _addEventToDatabase(String name, String category, String status, String date) async {
    await db.insertEvent(name, category, status, date, widget.userId);
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
                              'Category: ${event['location']} - Status: ${event['description']} - Date: ${event['date']}',
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
