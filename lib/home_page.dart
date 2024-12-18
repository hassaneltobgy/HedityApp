import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'eventListPage.dart'; // Import Event List Page
import 'MyEventListPage.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String firebaseUid;

  HomePage({required this.userId, required this.firebaseUid});

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];




  // Load friends for the current user from Firestore
  Future<void> _loadFriends() async {
    List<Map<String, dynamic>> allFriends = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('friends')
        .where('userUid', isEqualTo: widget.firebaseUid)
        .get();

    for (var doc in snapshot.docs) {
      String Friend_firebaseUid = doc['friendUid'];
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(Friend_firebaseUid).get();

      // Get profile data
      String name = userDoc['name'];
      String imagePath = userDoc['image_path'] ?? 'assets/Images/default_user_image.png';

      int upcomingEventsCount = await _getUpcomingEventsCount(Friend_firebaseUid);

      allFriends.add({
        'name': name,
        'profilePic': imagePath,
        'upcomingEvents': upcomingEventsCount.toString(),
        'id': Friend_firebaseUid,
      });
    }

    setState(() {
      friends = allFriends;
      filteredFriends = allFriends;
    });
  }

  Future<void> _deleteFriend(String friendUid) async {
    try {
      // Query Firestore to find the specific friend document for the current user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userUid', isEqualTo: widget.firebaseUid)
          .where('friendUid', isEqualTo: friendUid)
          .get();

      // Delete the friend document
      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance.collection('friends').doc(doc.id).delete();
      }

      // Update local state
      setState(() {
        friends.removeWhere((friend) => friend['id'] == friendUid);
        filteredFriends = friends; // Update the filtered list too
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete friend: $e')),
      );
    }
  }


  // Get upcoming events count for a friend
  Future<int> _getUpcomingEventsCount(String Friend_firebaseUid) async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userUid', isEqualTo: Friend_firebaseUid)
        .where('status', whereIn: ['Upcoming'])
        .get();

    return eventSnapshot.docs.length;
  }

  // Add a friend manually (search by phone number)
  void _addFriendManually() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend Manually'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
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
                if (phoneController.text.isNotEmpty) {
                  // Check if the phone number is registered
                  bool isRegistered = await _isPhoneNumberRegistered(phoneController.text);
                  if (isRegistered) {
                    String Friend_firebaseUid = await _getFirebaseUidByPhone(phoneController.text);

                    // Fetch user details and add to the list
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(Friend_firebaseUid).get();
                    int upcomingEventsCount = await _getUpcomingEventsCount(Friend_firebaseUid);

                    // Add the friend to the "friends" collection in Firestore
                    await FirebaseFirestore.instance.collection('friends').add({
                      'userUid': widget.firebaseUid,
                      'friendUid': Friend_firebaseUid,
                    });
                    await FirebaseFirestore.instance.collection('friends').add({
                      'userUid': Friend_firebaseUid,
                      'friendUid': widget.firebaseUid,
                    });

                    // Add the friend to the list
                    setState(() {
                      friends.add({
                        'name': userDoc['name'],
                        'profilePic': userDoc['image_path'] ?? 'assets/Images/default_user_image.png',
                        'upcomingEvents': upcomingEventsCount.toString(),
                        'id': Friend_firebaseUid,
                      });
                      filteredFriends = friends;
                    });

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Phone number is not registered')),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Check if the phone number is registered in Firestore
  Future<bool> _isPhoneNumberRegistered(String phone) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('PhoneNo', isEqualTo: phone)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Retrieve Firebase UID by phone number
  Future<String> _getFirebaseUidByPhone(String phone) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('PhoneNo', isEqualTo: phone)
        .get();

    return snapshot.docs.first.id;
  }
  void _navigateToEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyEventListPage(userId: widget.userId,firebaseUid:widget.firebaseUid)),
    );
  }
  // Navigate to friend's event list page
  void _navigateToFriendEvents(String friendId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(userId: widget.userId,firebaseUid:widget.firebaseUid,friendFirebaseUid:friendId),
      ),
    );
  }
  void _handleUnreadNotifications(String FirebaseUid) async {
    try {
      // Fetch unread notifications for the user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notification')
          .where('friendFirebaseUid', isEqualTo: FirebaseUid)
          .where('read', isEqualTo: 'No') // Fetch only unread notifications
          .get();

      if (snapshot.docs.isEmpty) return; // No notifications to show

      for (var doc in snapshot.docs) {
        // Extract the notification data
        Map<String, dynamic> notification = doc.data() as Map<String, dynamic>;
        String notificationId = doc.id;
        String message = notification['Notification'] ?? 'You have a new notification!';

        // Display notification as a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Mark as Read',
              onPressed: () async {
                // Mark the notification as read
                await FirebaseFirestore.instance
                    .collection('notification')
                    .doc(notificationId)
                    .update({'read': 'Yes'});
              },
            ),
          ),
        );

        // Optional: Add a slight delay between notifications to avoid overlapping SnackBars
        await Future.delayed(Duration(seconds: 6));
      }
    } catch (e) {
      // Handle errors (e.g., no connection, Firestore issues)
      print('Error fetching notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notifications. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    print("I am currently at init");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleUnreadNotifications(widget.firebaseUid);
    });
    _loadFriends(); // Load friends from Firestore
    _searchController.addListener(() {
      setState(() {
        filteredFriends = friends
            .where((friend) =>
            friend['name'].toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
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

        backgroundColor: Colors.black,
        elevation: 5,
        actions: [
          // Using Row to display text and icon next to each other
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  'Create Your Own Event',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.event, color: Colors.red),
                  onPressed: _navigateToEvent, // Navigate to profile page
                ),
              ],
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
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    hintText: 'Search for Friends...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addFriendManually,
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
                    'Add Friend Manually',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'List of Friends: ',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        return GestureDetector(
                          onTap: () => _navigateToFriendEvents(friend['id']),
                          child: Card(
                            color: Colors.black.withOpacity(0.6),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 15,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(friend['profilePic']),
                                    backgroundColor: Colors.grey,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      friend['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${friend['upcomingEvents']} upcoming events',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteFriend(friend['id']), // Call delete method
                                      ),
                                    ],
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
