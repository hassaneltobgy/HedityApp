import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GiftDetailsPage.dart'; // Import GiftDetailsPage
import 'myPledgedGiftsPage.dart'; // Import PledgedGiftsPage
import 'globals.dart'; // Import global variables
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'MyOwnGiftDetailsPage.dart' ;

class GiftListPage extends StatefulWidget {
  final Map<String, dynamic> event; // Entire event object passed
  final String firebaseUid;
  final String friendFirebaseUid;
//required this.firebaseUid, required this.friendFirebaseUid}
  GiftListPage({required this.event,required this.firebaseUid, required this.friendFirebaseUid});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> gifts = []; // Dynamically loaded gifts
  String? _sortBy = 'name'; // Default sorting by name

  @override
  void initState() {
    super.initState();
    _loadGifts(); // Load gifts for the specific event
  }

  Future<void> _loadGifts() async {
    String eventId = widget.event['FireBaseEventID']; // Extract eventId from event object

    // Fetch gifts from Firestore for the given eventId
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('event_id', isEqualTo: eventId)
          .get();

      setState(() {
        gifts = querySnapshot.docs.map((doc) {
          var giftData = doc.data() as Map<String, dynamic>;
          return {
            'name': giftData['name'],
            'description': giftData['description'],
            'category': giftData['category'],
            'price': giftData['price'],
            'image': giftData['image_path'], // Assuming image path is 'image_path'
            'FireBaseGiftID': doc.id, // Set Firestore gift ID
            'status': giftData['status']  // Assuming pledged status is in 'status'
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching gifts: $e');
    }
  }
  Color _getButtonColor(int status) {
    if (status == 0) {
      return Colors.grey; // Available
    } else if (status == 1) {
      return Colors.green; // Pledged
    } else if (status == 2) {
      return Colors.red; // Purchased
    }
    return Colors.grey; // Default
  }
  String _getButtonText(int status) {
    if (status == 0) {
      return "Pledge"; // Available
    } else if (status == 1) {
      return "Pledged"; // Already pledged
    } else if (status == 2) {
      return "Purchased"; // Purchased
    }
    return "Pledge"; // Default
  }

  Future<void> _togglePledge(int index) async {
    final gift = gifts[index];
    final giftId = gift['FireBaseGiftID'];
    final currentStatus = gift['status'];

    try {
      if (currentStatus == 0) {
        // Transition from status 0 to 1 (Pledged)
        await FirebaseFirestore.instance.collection('pledged_gifts').add({
          'firebaseUid': widget.firebaseUid,         // User who pledged
          'friendFirebaseUid': widget.friendFirebaseUid, // Friend whose gift is pledged
          'FireBaseGiftID': giftId,                 // Gift ID
        });

        await FirebaseFirestore.instance.collection('gifts').doc(giftId).update({
          'status': 1,
        });

        setState(() {
          gifts[index]['status'] = 1; // Update local UI
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gift marked as pledged.'),
            backgroundColor: Colors.red,
          ),
        );

        print('Gift pledged successfully!');
      } else if (currentStatus == 1) {
        // Check if the current user is the one who pledged the gift
        final querySnapshot = await FirebaseFirestore.instance
            .collection('pledged_gifts')
            .where('FireBaseGiftID', isEqualTo: giftId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final pledgedGift = querySnapshot.docs.first.data();
          final pledgedBy = pledgedGift['firebaseUid'];

          if (pledgedBy == widget.firebaseUid) {
            // Current user is the one who pledged; allow transition to status 2 (Purchased)
            await FirebaseFirestore.instance.collection('gifts').doc(giftId).update({
              'status': 2,
            });

            setState(() {
              gifts[index]['status'] = 2; // Update local UI
            });
            // Now, remove the gift from the 'pledged_gifts' collection as it has been purchased
            await FirebaseFirestore.instance.collection('pledged_gifts').where('firebaseUid', isEqualTo: widget.firebaseUid)
                .where('friendFirebaseUid', isEqualTo: widget.friendFirebaseUid)
                .where('FireBaseGiftID', isEqualTo: giftId)
                .get()
                .then((snapshot) async {
              if (snapshot.docs.isNotEmpty) {
                for (var doc in snapshot.docs) {
                  await FirebaseFirestore.instance.collection('pledged_gifts').doc(doc.id).delete();
                }
              }
            });

            //  Add the gift to the 'purchased_gifts' collection
            await  FirebaseFirestore.instance..collection('purchased_gifts').add({
              'firebaseUid': widget.firebaseUid,
              'friendFirebaseUid': widget.friendFirebaseUid,
              'FireBaseGiftID': giftId,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gift marked as purchased.'),
                backgroundColor: Colors.green,
              ),
            );
            // Optionally, you can show a message to the user that the gift has been marked as purchased

            print('Gift marked as purchased!');
          } else {
            // Someone else pledged the gift; show error message
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('This gift has already been pledged by someone else.'),
            ));
          }
        }
      } else if (currentStatus == 2) {
        // Gift is already purchased; no action allowed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('This gift has already been purchased.'),
        ));
      }
    } catch (e) {
      print('Error updating gift status: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
    }
  }




  void _navigateToGiftDetails(Map<String, dynamic> gift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage( gift:gift),
      ),
    );
  }

  void _navigateToPledgedGiftsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PledgedGiftsPage(firebaseUid:widget.firebaseUid)),
    );
  }

  void _sortGifts(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'name') {
        gifts.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (criteria == 'category') {
        gifts.sort((a, b) => a['category']!.compareTo(b['category']!));
      } else if (criteria == 'status') {
        gifts.sort((a, b) => (a['status'] ? 1 : 0).compareTo(b['status'] ? 1 : 0));
      }
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
        title: Text(
          'Gifts for ${widget.event['name']}',
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
            icon: Icon(Icons.list, color: Colors.red),
            onPressed: _navigateToPledgedGiftsPage,
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
                          _sortGifts(newValue);
                        }
                      },
                      items: <String>['name', 'category', 'status']
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
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return GestureDetector(
                        onTap: () => _navigateToGiftDetails(gift),
                        child: Card(
                          color: Colors.black.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.asset(
                                    gift['image'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gift['name'],
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '\$${gift['price'].toString()}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // The pledge button
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: _getButtonColor(gift['status']),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>_togglePledge(index),
                                    child: Text(
                                      _getButtonText(gift['status']),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
