import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GiftList.dart'; // Import GiftListPage
import 'user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class EventListPage extends StatefulWidget {
  final int userId;
  final String firebaseUid;
  final String friendFirebaseUid;

  EventListPage({required this.userId, required this.firebaseUid, required this.friendFirebaseUid});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];
  String? _sortBy = 'name'; // Default sorting by name

  // Function to go to profile page
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId, firebaseUid: widget.firebaseUid),
      ),
    );
  }

  // Function to navigate to GiftListPage
  void _goToGiftListPage(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(event: event,firebaseUid: widget.firebaseUid,friendFirebaseUid: widget.friendFirebaseUid), // Pass event data to GiftListPage
      ),
    );
  }

  // Sort events based on selected criteria
  void _sortEvents(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'name') {
        events.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (criteria == 'status') {
        events.sort((a, b) => a['status']!.compareTo(b['status']!));
      } else if (criteria == 'date') {
        events.sort((a, b) => a['date']!.compareTo(b['date']!));
      }
    });
  }

  // Load events for the specific friend (friendFirebaseUid)
  Future<void> _loadEvents() async {
    String friendFirebaseUid = widget.friendFirebaseUid; // Get the friendFirebaseUid passed from the previous page
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch events where userUid matches the friend's UID
    QuerySnapshot querySnapshot = await firestore
        .collection('events')
        .where('userUid', isEqualTo: friendFirebaseUid)
        .get();

    setState(() {
      events = querySnapshot.docs.map((doc) {
        var eventData = doc.data() as Map<String, dynamic>;
        return {
          'name': eventData['name'],
          'status': eventData['status'],
          'date': eventData['date'],
          'category':eventData['category'],
          'description':eventData['description'],
          'location':eventData['location'],
          'FireBaseEventID': doc.id

        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load events from Firestore
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
                      items: <String>['name', 'status', 'date']
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
                              'Status: ${event['status']} - Date: ${event['date']}',
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
