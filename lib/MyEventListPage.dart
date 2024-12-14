import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_programming_project/MyOwnGiftList.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'user_profile.dart';

class MyEventListPage extends StatefulWidget {

  final int userId;

  MyEventListPage({required this.userId});

  @override
  _MyEventListPageState createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  // Sample event data
  final db = DatabaseClass();
  List<Map<String, dynamic>> events = [];
  String? _sortBy = 'name'; // Default sorting by name

  // Function to add a new event
  void _goToProfile()
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId:widget.userId),
      ),);
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
                  await _addEventToDatabase(
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


  // Function to edit an event
  void _editEvent(int index) {
    final nameController = TextEditingController(text: events[index]['name']);
    final categoryController = TextEditingController(text: events[index]['location']);
    final statusController = TextEditingController(text: events[index]['description']);
    final dateController = TextEditingController(text: events[index]['date']);
    int eventId = events[index]['ID']; // Event ID from database

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
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    statusController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  // Update the event in the database
                  final db = DatabaseClass();
                  await db.updateEvent(
                    eventId,
                    nameController.text,
                    categoryController.text,
                    statusController.text,
                    dateController.text,
                  );

                  // Reload the events to reflect changes
                  await _loadEvents();

                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }


  // Function to delete an event
  Future<void> _deleteEventFromDatabase(int eventId) async {
    final db = DatabaseClass();
    await db.deleteEvent(eventId); // Add a deleteEvent method in DatabaseClass
    await _loadEvents(); // Refresh events after deletion
  }

  void _deleteEvent(int index) {
    int eventId = events[index]['ID']; // Replace with actual column name for event ID
    _deleteEventFromDatabase(eventId);
  }


  // Function to navigate to GiftListPage
  void _goToGiftListPage(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyOwnGiftListPage(event), // Pass event data to GiftListPage
      ),
    );
  }

  // Function to sort events based on selected criteria
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
  }

  Future<void> _addEventToDatabase(String name, String category, String status, String date) async {
    final db = DatabaseClass();
    await db.insertEvent(name, category, status, date, widget.userId);
    await _loadEvents(); // Refresh events after adding
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
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Darker overlay for opacity
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          // Main content area with padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Sort Dropdown Button
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
                // Add Event Button
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
                // Event List
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () {
                          _goToGiftListPage(event); // Navigate to GiftListPage on tap
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
                              event['name'], // Replace with actual column name
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            subtitle: Text(
                              'Category: ${event['location']} - Status: ${event['description']} - Date: ${event['date']}', // Replace with actual column names
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _editEvent(index), // Edit on icon press
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
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
