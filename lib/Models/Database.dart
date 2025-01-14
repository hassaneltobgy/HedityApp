import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseClass {
  static Database? _MyDataBase;
  final int version = 1;

  // Singleton pattern for accessing the database instance
  Future<Database?> get MyDataBase async {
    if (_MyDataBase == null) {
      _MyDataBase = await initialize();
    }
    return _MyDataBase;
  }

  // Initialize the database
  Future<Database> initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'myDatabase.db');

    return await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        // Create Users Table
        await db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        date_of_birth TEXT,
        gender TEXT,
        preferences TEXT,
        notification TEXT,
        image_path TEXT,
        PhoneNo TEXT NOT NULL UNIQUE
      )
      ''');

        // Create Events Table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          firebaseUid TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT NOT NULL,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          status TEXT NOT NULL ,
          user_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES Users (ID)
        )
      ''');

        // Create Gifts Table
        await db.execute('''
      CREATE TABLE IF NOT EXISTS Gifts (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT ,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL NOT NULL,
        image_path TEXT, 
        event_id INT NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES Events (ID)
      )
      ''');

        // Create Friends Table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Friends (
          user_id INTEGER NOT NULL,
          friend_id INTEGER NOT NULL,
          PRIMARY KEY (user_id, friend_id),
          FOREIGN KEY (user_id) REFERENCES Users (ID),
          FOREIGN KEY (friend_id) REFERENCES Users (ID)
        )
      ''');

        print("Database successfully created");
      },
    );
  }

  // CRUD operations
  // Read data
  Future<List<Map<String, dynamic>>> readData(String sql, [List<dynamic>? arguments]) async {
    final db = await MyDataBase;
    return await db!.rawQuery(sql, arguments);
  }

  // Insert data
  Future<int> insertData(String sql, [List<dynamic>? arguments]) async {
    final db = await MyDataBase;
    return await db!.rawInsert(sql, arguments);
  }


  // Update data
  Future<int> updateData(String sql, [List<dynamic>? arguments]) async {
    final db = await MyDataBase;
    return await db!.rawUpdate(sql, arguments);
  }

  // Delete data
  Future<int> deleteData(String sql, [List<dynamic>? arguments]) async {
    final db = await MyDataBase;
    return await db!.rawDelete(sql, arguments);
  }
  Future<bool> userExists(String email) async {
    var db = await openDatabase('myDatabase.db');
    var result = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );


    return result.isNotEmpty; // Return true if user exists, false otherwise
  }

  Future<int> deleteUserByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase; // Access the database instance
    return await db!.delete(
      'Users', // Table name
      where: 'firebaseUid = ?', // Condition to match the firebaseUid
      whereArgs: [firebaseUid], // Value to substitute in the condition
    );
  }

  Future<int> NewgetIdByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase; // Assuming MyDataBase is your database reference

    // Query the table and fetch the ID where firebaseUid matches the given value
    List<Map<String, dynamic>> result = await db!.query(
      'Users',
      columns: ['ID'], // Select only the ID column
      where: 'firebaseUid = ?', // Use where to filter by firebaseUid
      whereArgs: [firebaseUid], // Bind the firebaseUid to the query
    );

    // Since firebaseUid is guaranteed to exist in the database, we can return the ID directly
    return result.first['ID'];
  }

  Future<String?> getUserNameByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase;

    // Query the database for the user with the given firebaseUid
    final result = await db!.query(
      'Users', // Table name
      columns: ['name'], // Column to fetch
      where: 'firebaseUid = ?', // Condition
      whereArgs: [firebaseUid], // Argument for the condition
      limit: 1, // We only need one result
    );

    // If a matching user is found, return the name
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }

    // If no matching user is found, return null
    return null;
  }


  //Register -->  related Function
  Future<int> insertUser(String name, String email, String password, String dob, String gender, String preferences, String notification, String firebaseUid,String phoneno) async {
    final db = await MyDataBase;
    return await db!.insert('Users', {
      'name': name,
      'email': email,
      'password': password,
      'date_of_birth': dob,
      'gender': gender,
      'preferences': preferences,
      'notification': notification,
      'firebaseUid':firebaseUid,
      'image_path': 'assets/Images/default_user_image.png',
      'PhoneNo':phoneno,
    });
  }

  Future<void> updateUser({
    required int userId,
    required String name,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String preferences,
    required String notification,
    required String imagePath,
  }) async {
    try {
      final db = await MyDataBase; // Ensure you use the singleton instance of the database

      // Map to hold the new values for the update (excluding password)
      Map<String, dynamic> updatedFields = {
        'name': name,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'preferences': preferences,
        'notification': notification,
        'image_path': imagePath,
      };

      // Perform the update operation
      await db!.update(
        'Users', // Table name
        updatedFields, // Map containing the updated values
        where: 'ID = ?', // Update based on the user ID
        whereArgs: [userId], // User ID to match
      );

      print("User successfully updated for user ID: $userId");
    } catch (e) {
      print("Error updating user for user ID $userId: $e");
    }
  }



  // Authenticate User--> For login page
  Future<bool> authenticateUser(String email, String password) async {
    final db = await MyDataBase;
    List<Map<String, dynamic>> results = await db!.query(
      'Users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty; // Returns true if user is found
  }
  // Method to get userId by email to help in passing UserId Through pages
  Future<int?> getUserIdByEmail(String email) async {
    final db = await MyDataBase;

    // Query the Users table to get the userId where the email matches
    List<Map<String, dynamic>> result = await db!.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );

    // If the result is not empty, return the userId, otherwise return null
    if (result.isNotEmpty) {
      return result[0]['ID'];  // Return the userId from the first row of the result
    } else {
      return null;  // No user found with the given email
    }
  }

  // Function to set profile picture for the current user
  Future<void> setProfilePicture(int userId, String imagePath) async {
    try {
      // Update the image_path field for the user with the given ID
      final db = await MyDataBase;
      await db!.update(
        'Users',
        {'image_path': imagePath},
        where: 'ID = ?', // Condition
        whereArgs: [userId], // Arguments for the condition
      );
      print("Profile picture updated successfully for user ID: $userId");
    } catch (e) {
      print("Error updating profile picture: $e");
    }
  }

  Future<void> updateUserImage(int userId, String imagePath) async {
    try {
      final db = await MyDataBase; // Ensure you use the singleton instance of the database

      // Update the image_path field in the Users table for the specified user ID
      await db!.update(
        'Users', // Table name
        {'image_path': imagePath}, // Field to update
        where: 'ID = ?', // Condition to match the user ID
        whereArgs: [userId], // User ID value to match
      );

      print("Profile picture updated successfully for user ID: $userId");
    } catch (e) {
      print("Error updating profile picture for user ID $userId: $e");
    }
  }


  Future<Map<String, dynamic>> getUserById(int userId) async {
    final db = await MyDataBase;
    final result = await db!.query('Users', where: 'ID = ?', whereArgs: [userId]);
    return result.first;
  }

  //Needed for firebase Authentication
  Future<int?> getUserIdByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase;
    List<Map> result = await db!.query(
      'Users',
      where: 'firebaseUid = ?',
      whereArgs: [firebaseUid],
    );

    Future<String?> getFirebaseUidById(int id) async {
      final db = await MyDataBase; // Assuming MyDataBase is your database instance
      List<Map> result = await db!.query(
        'Users',
        where: 'ID = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return result.first['firebaseUid']; // Return firebaseUid
      } else {
        print('No user found with ID: $id');
        return null;
      }
    }


    if (result.isNotEmpty) {
      return result.first['ID'] as int?;
    } else {
      return null; // No user found with the given Firebase UID
    }
  }



// Method to insert a new friend--> Homepage
  Future<int> insertFriend(String name, String profilePic, String upcomingEvents) async {
    final db = await MyDataBase;
    return await db!.insert('Friends', {
      'name': name,
      'profilePic': profilePic,
      'upcomingEvents': upcomingEvents,
    });


  }
// Method to fetch all friends --> HomePage
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await MyDataBase;

    // Query the 'Friends' table and filter by userId
    return await db!.query(
      'Friends',
      where: 'user_id = ?',
      whereArgs: [userId], // Use the provided userId
    );
  }



  // **********Methods for -->EventListPage *************
// Method to insert a new event

  Future<List<Map<String, dynamic>>> getEventsForUser(int userId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }




// Method to fetch events for a specific user/friend
  Future<List<Map<String, dynamic>>> getEvents(int userId) async {
    final db = await MyDataBase;
    return await db!.query('Events', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Fetch events for a specific friend based on friendId
  Future<List<Map<String, dynamic>>> getEventsForFriend(int friendId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'friend_id = ?', // Assuming you have a column friend_id in the Events table
      whereArgs: [friendId],
    );
  }


  //Get Gifts For Events--> GiftListPage related


  //*********Methods For MyEventListPage ***********


  Future<void> insertEvent(String name,String Firebaseuid, String category, String status, String date,String location,String description, int userId) async {
    final db = await MyDataBase;
    await db!.insert('Events', {
      'name': name,
      'firebaseUid':Firebaseuid,
      'date': date,
      'location':location,
      'category': category,
      'description': description,
      'user_id': userId,
      'status':status,
    });
  }

  Future<int?> getEventIdByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase;

    // Perform the query to get the ID based on firebaseUid
    final result = await db!.query(
      'Events', // The table you want to query
      columns: ['ID'], // We only need the ID column
      where: 'firebaseUid = ?', // Condition to match the firebaseUid
      whereArgs: [firebaseUid], // The argument that will be used in the query
    );

    // Check if a result was found and return the ID as an integer
    return result.isNotEmpty ? result.first['ID'] as int : null;
  }


  Future<void> deleteEvent(int eventId) async {
    final db = await MyDataBase;
    await db!.delete('Events', where: 'ID = ?', whereArgs: [eventId]);
  }


  Future<void> updateEvent(int eventId, String name, String category,String location, String status, String date,String description) async {
    final db = await MyDataBase;
    await db!.update(
      'Events',
      {
        'name': name,
        'date': date,
        'location':location,
        'category': category,
        'description': description,
        'status':status,
      },
      where: 'ID = ?',
      whereArgs: [eventId],
    );
  }
  Future<List<Map<String, dynamic>>> getEventByFirebaseUid(String firebaseUid) async {
    final db = await MyDataBase;
    return await db!.query(
      'Events',
      where: 'firebaseUid = ?', // Match firebaseUid in the Events table
      whereArgs: [firebaseUid],
    );
  }
  Future<String?> getEventFirebaseUid(int localEventId) async {
    final db = await MyDataBase; // Get the database instance
    final List<Map<String, dynamic>> result = await db!.query(
      'Events',              // Table name
      columns: ['firebaseUid'],  // Column to retrieve
      where: 'ID = ?',       // Filter condition
      whereArgs: [localEventId], // Arguments for the condition
    );



    if (result.isNotEmpty) {
      return result.first['firebaseUid'] as String; // Return the firebaseUid
    } else {
      return null; // Return null if no matching event is found
    }
  }


  Future<List<Map<String, dynamic>>> getGiftByEventIdAndName(String eventId, String giftName) async {
    final db = await MyDataBase;
    return await db!.query(
      'Gifts',
      where: 'event_id = ? AND name = ?', // Match both event_id and gift name
      whereArgs: [eventId, giftName],
    );
  }




  //******** MyOwnGiftListpage***********
  // Insert a new gift into the database

  Future<void> insertGift(String name, String description, String category, double price, String imagePath, int eventId, int is_pledged) async {
    final db = await MyDataBase;
    await db!.insert(
      'Gifts',
      {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'image_path': imagePath,  // Save the image path
        'event_id': eventId,
        'status':is_pledged,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGiftFromFireStore(String name, String description, String category, double price, String imagePath, String FirebaseGiftId, int is_pledged) async {
    final db = await MyDataBase;
    await db!.insert(
      'Gifts',
      {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'image_path': imagePath,  // Save the image path
        'firebaseUid': FirebaseGiftId,
        'status':is_pledged,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future<void> updateGift(int giftId, String name, String description, String category, double price, String imagePath) async {
    final db = await MyDataBase;

    await db!.update(
      'Gifts', // Table name
      {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'image_path': imagePath, // Update the image path
      },
      where: 'ID = ?', // Condition to match the gift ID
      whereArgs: [giftId],
    );
  }




  // Delete a gift from the database

  Future<void> deleteGift(int giftId) async {
    final db = await MyDataBase;
    await db!.delete(
      'Gifts',
      where: 'ID = ?',
      whereArgs: [giftId],
    );
  }
  Future<int> getGiftStatus(int giftId) async {
    final db = await MyDataBase;

    // Query the 'Gifts' table for the 'status' column where 'ID' matches the provided giftId
    List<Map> result = await db!.query(
      'Gifts', // The table name
      columns: ['status'], // We only want the 'status' column
      where: 'ID = ?', // Filter by 'ID'
      whereArgs: [giftId], // Pass the giftId as the argument
    );

    // Since the 'status' column is not nullable, we can safely access it
    return result.first['status'] as int;
  }


  // Get all gifts for a specific event
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    final db = await MyDataBase;
    return await db!.query(
      'Gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> updateGiftFirebaseUid(int giftId, String firebaseGiftId) async {
    final db = await MyDataBase; // Get the database instance
    await db!.update(
      'Gifts', // Table name
      {'firebaseUid': firebaseGiftId}, // Field to update
      where: 'ID = ?', // Condition to identify the record
      whereArgs: [giftId], // Arguments to replace '?' in the query
    );
  }




}
