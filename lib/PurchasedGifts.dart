import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'user_profile.dart';

class PurchasedGiftsPage extends StatefulWidget {

  final String firebaseUid;
  PurchasedGiftsPage({required this.firebaseUid});

  @override
  _PurchasedGiftsPageState createState() => _PurchasedGiftsPageState();
}

class _PurchasedGiftsPageState extends State<PurchasedGiftsPage> {
  late Future<List<Map<String, dynamic>>> pledgedGiftsFuture;
  final DatabaseClass mydb = DatabaseClass();

  @override
  void initState() {
    super.initState();
    pledgedGiftsFuture = _fetchPledgedGifts();
  }

  /// Fetch pledged gifts based on `firebaseUid`.
  Future<List<Map<String, dynamic>>> _fetchPledgedGifts() async {
    try {
      // Step 1: Get FireBaseGiftIDs from purchased_gifts where firebaseUid matches
      QuerySnapshot pledgedGiftsSnapshot = await FirebaseFirestore.instance
          .collection('purchased_gifts')
          .where('firebaseUid', isEqualTo: widget.firebaseUid)
          .get();

      List<String> giftIds = pledgedGiftsSnapshot.docs
          .map((doc) => doc['FireBaseGiftID'] as String)
          .toList();

      // Step 2: Fetch gift details from the gifts collection using the FireBaseGiftIDs
      List<Map<String, dynamic>> gifts = [];
      for (String giftId in giftIds) {
        DocumentSnapshot giftSnapshot = await FirebaseFirestore.instance
            .collection('gifts')
            .doc(giftId)
            .get();
        if (giftSnapshot.exists) {
          gifts.add(giftSnapshot.data() as Map<String, dynamic>);
        }
      }

      return gifts;
    } catch (error) {
      print('Error fetching pledged gifts: $error');
      return [];
    }
  }

  void _navigateToMyProfile()async {
      int userId= await mydb.NewgetIdByFirebaseUid(widget.firebaseUid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId:userId, firebaseUid:widget.firebaseUid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Purchased Gifts',
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.red),
            onPressed: _navigateToMyProfile,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pledgedGiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading pledged gifts.',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No pledged gifts yet.',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          } else {
            final pledgedGifts = snapshot.data!;

            return ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = pledgedGifts[index];
                print('$gift');
                return Card(
                  color: Colors.black.withOpacity(0.6),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0), // Adjust padding to ensure no overflow
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
                      children: [
                        // Image container with dynamic size based on screen width
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: gift['image_path'] != null
                              ? Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                            height: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                            child: Image.asset(
                              gift['image_path'],
                              fit: BoxFit.cover, // Ensure the image fills the container
                            ),
                          )
                              : Container(
                            width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                            height: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                            child: Icon(
                              Icons.image,
                              size: MediaQuery.of(context).size.width * 0.1, // Icon size based on screen width
                              color: Colors.red,
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.04), // Spacing based on screen width
                        // Text details with dynamic font size
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gift['name'] ?? 'No Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * 0.05, // Font size based on screen width
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // Handle long text
                              ),
                              SizedBox(height: 5),
                              Text(
                                gift['price'] != null
                                    ? '\$${gift['price'].toStringAsFixed(2)}'
                                    : 'No Price',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: MediaQuery.of(context).size.width * 0.04, // Font size based on screen width
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // Handle long text
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );

              },
            );
          }
        },
      ),
    );
  }
}
