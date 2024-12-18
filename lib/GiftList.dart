import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GiftDetailsPage.dart'; // Import GiftDetailsPage
import 'myPledgedGiftsPage.dart'; // Import PledgedGiftsPage
import 'globals.dart'; // Import global variables
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'MyOwnGiftDetailsPage.dart' ;

class GiftListPage extends StatefulWidget {
  final Map<String, dynamic> event; // Entire event object passed

  GiftListPage({required this.event});

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

  void _togglePledge(int index) {
    setState(() {
      gifts[index]['status'] = !gifts[index]['status'];
      if (gifts[index]['status']) {
        globalPledgedGifts.add(gifts[index]);
      } else {
        globalPledgedGifts.removeWhere((gift) => gift['name'] == gifts[index]['name']);
      }
    });
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
      MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
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
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: (gift['status'] == 1) ? Colors.red : Colors.grey, // Changes button color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8), // Optional rounded corners
                                      ),
                                    ),
                                    onPressed: () => _togglePledge(index),
                                    child: Text(
                                      "Pledge",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white, // Text color stays white for contrast
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
