import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // USERS COLLECTION

  // Add a new user
  Future<void> addUser_Firestore(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('Users').doc(uid).set(userData);
      print("User added successfully To FireStore ");
    } catch (e) {
      print("Error adding user To Firestore: $e");
    }
  }

  // Get user data by Firebase UID
  Future<DocumentSnapshot?> getUserByUid_FireStore(String uid) async {
    try {
      return await _firestore.collection('Users').doc(uid).get();
    } catch (e) {
      print("Error fetching user From FireStore: $e");
      return null;
    }
  }

  // Update user data
  Future<void> updateUser_FireStore(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Users').doc(uid).update(updatedData);
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // EVENTS COLLECTION

  // Add a new event
  Future<void> addEvent_FireStore(String userId, Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('Users').doc(userId).collection('Events').add(eventData);
      print("Event added successfully");
    } catch (e) {
      print("Error adding event: $e");
    }
  }

  // Get all events for a user
  Future<QuerySnapshot?> getEventsForUser_FireStore(String userId) async {
    try {
      return await _firestore.collection('Users').doc(userId).collection('Events').get();
    } catch (e) {
      print("Error fetching events: $e");
      return null;
    }
  }

  // Update an event
  Future<void> updateEvent_FireStore(String userId, String eventId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Users').doc(userId).collection('Events').doc(eventId).update(updatedData);
      print("Event updated successfully");
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  // Delete an event
  Future<void> deleteEvent_FireStore(String userId, String eventId) async {
    try {
      await _firestore.collection('Users').doc(userId).collection('Events').doc(eventId).delete();
      print("Event deleted successfully");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // GIFTS COLLECTION

  // Add a new gift
  Future<void> addGift_FireStore(String userId, String eventId, Map<String, dynamic> giftData) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .add(giftData);
      print("Gift added successfully");
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  // Get all gifts for an event
  Future<QuerySnapshot?> getGiftsForEvent_FireStore(String userId, String eventId) async {
    try {
      return await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .get();
    } catch (e) {
      print("Error fetching gifts: $e");
      return null;
    }
  }

  // Update a gift
  Future<void> updateGift_FireStore(String userId, String eventId, String giftId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .doc(giftId)
          .update(updatedData);
      print("Gift updated successfully");
    } catch (e) {
      print("Error updating gift: $e");
    }
  }

  // Delete a gift
  Future<void> deleteGift_FireStore(String userId, String eventId, String giftId) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .doc(giftId)
          .delete();
      print("Gift deleted successfully");
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

  // Function for Adding Friend
// Add a friend by storing their Firebase UID in the 'friends' sub-collection
  Future<void> addFriend_FireStore(String FireBase_userId, String FireBase_friendId) async {
    try {
      await _firestore.collection('Users').doc(FireBase_userId).collection('Friends').doc(FireBase_friendId).set({
        'friendId': FireBase_friendId,  // Storing friend’s Firebase UID
        // Optional: You can add other metadata about the friendship (like status)
      });
      print("Friend added successfully");
    } catch (e) {
      print("Error adding friend: $e");
    }
  }

  // Get all friends for a user


  // Remove a friend by deleting the friend's document from the 'friends' sub-collection
  Future<void> removeFriend_FireStore(String userId, String friendId) async {
    try {
      await _firestore.collection('Users').doc(userId).collection('Friends').doc(friendId).delete();
      print("Friend removed successfully");
    } catch (e) {
      print("Error removing friend: $e");
    }
  }

  //This function only retrieves Firebase Id For friends
  Future<QuerySnapshot?> getFriendsForUser_FireStore(String userId) async {
    try {
      return await _firestore.collection('Users').doc(userId).collection('Friends').get();
    } catch (e) {
      print("Error fetching friends: $e");
      return null;
    }
  }
//This function Retrieve Specific friend object  using their Firebase UID
  Future<DocumentSnapshot?> getFriendData_FireStore(String friendId) async {
    try {
      return await _firestore.collection('Users').doc(friendId).get();
    } catch (e) {
      print("Error fetching friend's data: $e");
      return null;
    }
  }


}