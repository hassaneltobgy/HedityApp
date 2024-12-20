import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_programming_project/MyEventListPage.dart';
import 'package:mobile_programming_project/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_programming_project/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


Future<void> waitForUiToAppear(WidgetTester tester, String friendName,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final startTime = DateTime.now();
  final friendFinder = find.text(friendName);

  while (findsNothing.matches(friendFinder, {})) {
    await tester.pump(); // Rebuild the widget tree
    if (DateTime.now().difference(startTime) > timeout) {
      throw Exception('Timeout: Friend "$friendName" did not appear in the UI.');
    }
  }
}

void main()async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  group('Login Page Integration Test', () {
    testWidgets('successful login navigation to HomePage', (tester) async {
      // Load the app
      await tester.pumpWidget(MyApp());

      // Wait for the LoginPage to load
      await tester.pumpAndSettle();

      // Find the email and password TextFormFields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');

      // Enter valid email and password
      await tester.enterText(emailField, 'hassan@gmail.com');
      await tester.enterText(passwordField, 'hassan@gmail.com');

      // Tap on the login button
      await tester.tap(loginButton);

      // Wait for the loading indicator to disappear and HomePage to load
      await tester.pumpAndSettle();

      //Navigate to create Your own event
      final iconFinder = find.byIcon(Icons.event);
      expect(iconFinder, findsOneWidget);

      // Simulate a tap on the IconButton
      await tester.tap(iconFinder);
      await tester.pumpAndSettle(); // Wait for navigation to complete

      //Click on Add New Event
      final addMyNewEventButton = find.widgetWithText(ElevatedButton, 'Add New Event');
      expect(addMyNewEventButton, findsOneWidget);
      await tester.tap(addMyNewEventButton);
      await tester.pumpAndSettle(); // Wait for the dialog to appear

      //Enter Event Details:
      // Find the email and password TextFormFields

      final MyEventName = find.byKey(Key('MyEventName'));
      final MyCategory = find.byKey(Key('MyCategory'));
      final MyDescription = find.byKey(Key('MyDescription'));
      final MyDate = find.byKey(Key('MyDate'));
      final MyLocation = find.byKey(Key('MyLocation'));

      expect(MyEventName, findsOneWidget);
      expect(MyCategory, findsOneWidget);
      expect(MyDescription, findsOneWidget);
      expect(MyDate, findsOneWidget);
      expect(MyLocation, findsOneWidget);

      await tester.enterText(MyEventName, 'My Birthday');
      await tester.enterText(MyCategory, 'BirthDay');
      await tester.enterText(MyDescription, 'A Party for My Birthday');
      await tester.enterText(MyDate, '2025-05-05');
      await tester.enterText(MyLocation, 'My Home');

      // Tap on the login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Event'));
       await tester.pump();
      await tester.pumpAndSettle();

      final eventTile = find.text('My Birthday');
     expect(eventTile, findsOneWidget);
      await tester.tap(eventTile);
       await tester.pumpAndSettle();





      // Find the specific event by Key

      expect(find.text('Add New Gift'), findsOneWidget);


      // Find and tap the Add Gift button
        final addGiftButton = find.widgetWithText(ElevatedButton, 'Add New Gift');
        expect(addGiftButton, findsOneWidget);
       await tester.tap(addGiftButton);
      await tester.pumpAndSettle();

      //After this it means I am at myOwnGiftlistPage

      final AddNewGift = find.widgetWithText(ElevatedButton, 'Add New Gift');
      expect(AddNewGift, findsOneWidget);
      await tester.tap(AddNewGift);
      await tester.pump(); // Trigger the UI update

      await waitForUiToAppear(tester, 'Gift Name');
      //Now start inputting the GiftDetails
      final MyGiftName = find.byKey(Key('MyGiftName'));
      final MyGiftDescription = find.byKey(Key('MyGiftDescription'));
      final MyGiftCategory = find.byKey(Key('MyGiftCategory'));
      final MyGiftPrice=find.byKey(Key('MyGiftPrice'));

      expect(MyGiftName, findsOneWidget);
      expect(MyGiftDescription, findsOneWidget);
      expect(MyGiftCategory, findsOneWidget);
      expect(MyGiftPrice, findsOneWidget);

      await tester.enterText(MyGiftName, 'Head Phone');
      await tester.enterText(MyGiftDescription, 'Extremly Amazing Headphone');
      await tester.enterText(MyGiftCategory, 'Electronics');
      await tester.enterText(MyGiftPrice, '1650');

      //

      final ChooseanImage = find.widgetWithText(ElevatedButton, 'Choose an Image');
      expect(ChooseanImage, findsOneWidget);
      await tester.tap(ChooseanImage);
      await tester.pump(); // Trigger the UI update

      await waitForUiToAppear(tester, 'Select an Image');
    //Now we can see list of gifts
      final HeadPhoneObject=find.text('Headphone');
      expect(HeadPhoneObject, findsOneWidget);
      await tester.tap(HeadPhoneObject);
      await tester.pumpAndSettle();

    //After this we tapped on headphone

      final AddGiftToEvent = find.widgetWithText(ElevatedButton, 'Add Gift');
      expect(AddGiftToEvent, findsOneWidget);
      await tester.tap(AddGiftToEvent);
      await tester.pump(); // Trigger the UI update

      await waitForUiToAppear(tester, 'Head Phone');
    //After this Gift has been added

      final MyHeadPhoneGiftCard = find.text('Head Phone');
      expect(MyHeadPhoneGiftCard, findsOneWidget);
      await tester.tap(MyHeadPhoneGiftCard);
      await tester.pumpAndSettle();


      await waitForUiToAppear(tester, 'Gift Name');
      final MyGiftNameDetails = find.text('Gift Name');
      expect(MyGiftNameDetails, findsOneWidget);











//
// // Simulate tapping on the friend's card
//       await tester.tap(testCard);
//       await tester.pumpAndSettle();
//
// /* *************Adding Friend******************/
//       // Locate and press the 'Add Friend Manually' button
//       final addFriendButton = find.widgetWithText(ElevatedButton, 'Add Friend Manually');
//       expect(addFriendButton, findsOneWidget);
//       await tester.tap(addFriendButton);
//       await tester.pumpAndSettle(); // Wait for the dialog to appear
//
//       // Enter the phone number in the dialog
//       final phoneTextField = find.byKey(Key('phoneTextField'));
//       expect(phoneTextField, findsOneWidget);
//
//       await tester.enterText(phoneTextField, '01001441802');
//       await tester.pump(); // Trigger the UI update
//
//       // Locate and press the 'Add' button to add the friend
//       final addButton = find.widgetWithText(ElevatedButton, 'Add');
//       expect(addButton, findsOneWidget);
//       await tester.tap(addButton);
//       await tester.pumpAndSettle(); // Wait for Firestore data to load
//
//       // After the friend is added, look for "Hassan" in the friend list
//       // Wait for Firestore data to be reflected in the UI
//       // Wait for "Hassan" to appear in the list
//       await waitForUiToAppear(tester, 'Test');
//
// // Find the friend's card (GestureDetector containing the Text 'Hassan')
//       final testCard = find.text('Hassan');
//       expect(testCard, findsOneWidget);
//
// // Simulate tapping on the friend's card
//       await tester.tap(testCard);
//       await tester.pumpAndSettle(); // Wait for navigation to complete
//       // You can assert something on the next screen (Event List Page)
//       final eventListPage = find.byType(MyEventListPage);
//       expect(eventListPage, findsOneWidget);
//


    });
  });
}
