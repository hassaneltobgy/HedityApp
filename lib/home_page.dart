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
      QuerySnapshot reversesnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userUid', isEqualTo: friendUid)
          .where('friendUid', isEqualTo: widget.firebaseUid)
          .get();

      // Delete the friend document
      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance.collection('friends').doc(doc.id).delete();
      }

      for (var doc2 in reversesnapshot.docs) {
        await FirebaseFirestore.instance.collection('friends').doc(doc2.id).delete();
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
                String phoneNumber = phoneController.text.trim();
                if (phoneNumber.isEmpty || !RegExp(r'^01\d{9}$').hasMatch(phoneNumber)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Make sure PhoneNo is Not Empty And 11 digit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.red, // Red background for the SnackBar
                      duration: Duration(seconds: 3), // Set duration to make it visible for 3 seconds
                      behavior: SnackBarBehavior.floating, // Optional: makes the SnackBar float above content
                      action: SnackBarAction(
                        label: 'Okay',
                        onPressed: () {
                          // You can add an action, for example, closing the SnackBar
                        },
                        textColor: Colors.white, // Action text color
                      ),
                    ),
                  );

                  return;
                }
                if (phoneController.text.isNotEmpty) {
                  // Check if the phone number is registered
                  bool isRegistered = await _isPhoneNumberRegistered(phoneController.text);
                  if (isRegistered) {
                    String Friend_firebaseUid = await _getFirebaseUidByPhone(phoneController.text);

                    // Check if they are already friends
                    var querySnapshot = await FirebaseFirestore.instance
                        .collection('friends')
                        .where('userUid', isEqualTo: widget.firebaseUid)
                        .where('friendUid', isEqualTo: Friend_firebaseUid)
                        .get();



                    if (querySnapshot.docs.isEmpty ) {
                      // Not already friends, proceed to add
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
                      // Already friends
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'You are Already Friends with this User',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.red, // Red background for the SnackBar
                          duration: Duration(seconds: 5), // Set duration to make it visible for 3 seconds
                          behavior: SnackBarBehavior.floating, // Optional: makes the SnackBar float above content
                          action: SnackBarAction(
                            label: 'Okay',
                            onPressed: () {
                              // You can add an action, for example, closing the SnackBar
                            },
                            textColor: Colors.white, // Action text color
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Phone Number is not registered',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red, // Red background for the SnackBar
                        duration: Duration(seconds: 3), // Set duration to make it visible for 3 seconds
                        behavior: SnackBarBehavior.floating, // Optional: makes the SnackBar float above content
                        action: SnackBarAction(
                          label: 'Okay',
                          onPressed: () {
                            // You can add an action, for example, closing the SnackBar
                          },
                          textColor: Colors.white, // Action text color
                        ),
                      ),
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
            content: Row(
              children: [
                Icon(Icons.notifications, color: Colors.white), // Add an icon to make it more visually appealing
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white, // White text for contrast
                      fontSize: 12, // Increase the font size slightly for readability
                      fontWeight: FontWeight.bold, // Make the text bold for emphasis
                      letterSpacing: 1.2, // Add letter spacing for a more open feel
                      shadows: [
                        Shadow(
                          blurRadius: 4.0, // Add blur to the shadow
                          color: Colors.black.withOpacity(0.5), // Subtle black shadow for depth
                          offset: Offset(2.0, 2.0), // Position the shadow slightly to the bottom-right
                        ),
                      ],
                    )
                    // White text for contrast
                  ),
                ),
              ],
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.black, // Black background for consistency with theme
            behavior: SnackBarBehavior.floating, // Makes the snackbar float above content
            margin: EdgeInsets.all(16), // Adds space around the snackbar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            action: SnackBarAction(
              label: 'Mark as Read',
              textColor: Colors.red, // Red text for the action button
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
                  'List of Friends:',
                  style:TextStyle(
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
                                    backgroundImage: AssetImage(friend['profilePic']), // friend['profilePic'] should be a relative path to your asset
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
