import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GiftDetailsPage.dart'; // Import GiftDetailsPage
import 'myPledgedGiftsPage.dart'; // Import PledgedGiftsPage
import 'globals.dart'; // Import global variables
import 'package:mobile_programming_project/Models/Database.dart';

class GiftListPage extends StatefulWidget {
  final Map<String, dynamic> event; // Entire event object passed

  GiftListPage({required this.event});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  DatabaseClass mydb = DatabaseClass(); // Instance of the database
  List<Map<String, dynamic>> gifts = []; // Dynamically loaded gifts
  String? _sortBy = 'name'; // Default sorting by name

  @override
  void initState() {
    super.initState();
    _loadGifts(); // Load gifts for the specific event
  }

  Future<void> _loadGifts() async {
    int eventId = widget.event['id']; // Extract eventId from event object
    List<Map<String, dynamic>> dbGifts = await mydb.getGiftsForEvent(eventId);

    setState(() {
      gifts = dbGifts; // Update the gifts list with database data
    });
  }

  void _togglePledge(int index) {
    setState(() {
      gifts[index]['isPledged'] = !gifts[index]['isPledged'];
      if (gifts[index]['isPledged']) {
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
        builder: (context) => GiftDetailsPage(gift:gift),
      ),
    );
  }

  void _navigateToPledgedGiftsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
    );
  }

  void _editGift(int index) {
    final nameController = TextEditingController(text: gifts[index]['name']);
    final descriptionController = TextEditingController(text: gifts[index]['description']);
    final categoryController = TextEditingController(text: gifts[index]['category']);
    final priceController = TextEditingController(text: gifts[index]['price'].toString());
    final imageController = TextEditingController(text: gifts[index]['image']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                setState(() {
                  gifts[index] = {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'category': categoryController.text,
                    'price': double.tryParse(priceController.text) ?? 0,
                    'isPledged': gifts[index]['isPledged'],
                    'image': imageController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  void _sortGifts(String criteria) {
    setState(() {
      _sortBy = criteria;
      if (criteria == 'name') {
        gifts.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (criteria == 'category') {
        gifts.sort((a, b) => a['category']!.compareTo(b['category']!));
      } else if (criteria == 'status') {
        gifts.sort((a, b) => (a['isPledged'] ? 1 : 0).compareTo(b['isPledged'] ? 1 : 0));
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
                                      '\$${gift['price'].toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                child: ElevatedButton(
                                  onPressed: () => _togglePledge(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gift['isPledged'] ? Colors.red : Colors.grey[700],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    gift['isPledged'] ? 'Pledged' : 'Pledge',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
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
