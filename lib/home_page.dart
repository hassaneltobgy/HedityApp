import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'eventListPage.dart'; // Import EventListPage
import 'package:flutter/services.dart';
import 'MyEventListPage.dart';

class HomePage extends StatefulWidget {
  final int userId;

  HomePage({required this.userId});

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseClass mydb = DatabaseClass();
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends(); // Load friends from the database

    _searchController.addListener(() {
      setState(() {
        filteredFriends = friends
            .where((friend) =>
            friend['name'].toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  // Load friends for the current user from the database
  Future<void> _loadFriends() async {
    List<Map<String, dynamic>> allFriends = await mydb.getFriends(widget.userId);
    setState(() {
      friends = allFriends;
      filteredFriends = allFriends;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add a friend manually (save to DB)
  void _addFriendManually() {
    final nameController = TextEditingController();
    final eventsController = TextEditingController();
    final genderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend Manually'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                TextField(controller: eventsController, decoration: InputDecoration(labelText: 'Upcoming Events')),
                TextField(controller: genderController, decoration: InputDecoration(labelText: 'Gender (M/F)')),
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
                    eventsController.text.isNotEmpty &&
                    (genderController.text.toLowerCase() == 'm' || genderController.text.toLowerCase() == 'f')) {
                  // Add the friend to the database
                  await mydb.insertFriend(nameController.text,
                      genderController.text.toLowerCase() == 'm'
                          ? 'assets/Images/male.png'
                          : 'assets/Images/female.png',
                      eventsController.text);

                  // Reload friends list after adding new friend
                  await _loadFriends();

                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add a friend from contacts
  Future<void> _addFriendFromContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: contact.photo != null
                    ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                    : CircleAvatar(child: Text(contact.displayName[0])),
                title: Text(contact.displayName),
                onTap: () {
                  setState(() {
                    friends.add({
                      'name': contact.displayName,
                      'profilePic': 'assets/Images/default_profile.png',
                      'upcomingEvents': '0', // Default to no upcoming events
                    });
                    filteredFriends = friends;
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access contacts was denied')),
      );
    }
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: Text('How would you like to add a friend?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addFriendManually();
              },
              child: Text('Enter Manually'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addFriendFromContacts();
              },
              child: Text('Select from Contacts'),
            ),
          ],
        );
      },
    );
  }

  void _createEventOrList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEventListPage(userId: widget.userId),
      ),
    );
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
        title: Text(
          'Friends List',
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
              onTap: _createEventOrList,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Create Your Own Event',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
                  onPressed: _addFriend,
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
                    'Add Friend',
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
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventListPage(friendId: friend['id'],userId:widget.userId), // Pass friend ID here
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.black.withOpacity(0.6),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 15,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(friend['profilePic']),
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
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Upcoming Events: ${friend['upcomingEvents']}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
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
