import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GiftList.dart'; // Import GiftListPage
import 'user_profile.dart';
import 'package:mobile_programming_project/Models/Database.dart';

class EventListPage extends StatefulWidget {
  final int friendId; // Declare friendId to be received from the previous page
  final int userId;

  EventListPage({required this.friendId,required this.userId});
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  DatabaseClass mydb = DatabaseClass();
  List<Map<String, dynamic>> events = [];
  String? _sortBy = 'name'; // Default sorting by name
  // Function to go to profile page
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );
  }

  // Function to navigate to GiftListPage
  void _goToGiftListPage(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(event: event), // Pass event data to GiftListPage
      ),
    );
  }

  // Sort events based on selected criteria
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
  // Load events for the specific friend (friendId)
  Future<void> _loadEvents() async {
    int friendId = widget.friendId; // Get the friendId passed from HomePage
    List<Map<String, dynamic>> dbEvents = await mydb.getEventsForFriend(friendId); // Assuming you have a method to fetch events for a friend
    setState(() {
      events = dbEvents.map((event) => {
        'name': event['name'],
        'category': event['category'],
        'status': event['status'],
        'date': event['date'],
      }).toList();
    });
  }
  @override
  void initState() {
    super.initState();
    _loadEvents();  // Load events from the database
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
              onTap: _goToProfile, // Navigate to the profile page
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
          // Background Image and overlay
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
                              event['name']!,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            subtitle: Text(
                              'Category: ${event['category']} - Status: ${event['status']} - Date: ${event['date']}',
                              style: TextStyle(color: Colors.white70),
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