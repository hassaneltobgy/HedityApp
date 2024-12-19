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
      await tester.enterText(emailField, 'samia@gmail.com');
      await tester.enterText(passwordField, 'samia@gmail.com');

      // Tap on the login button
      await tester.tap(loginButton);

      // Wait for the loading indicator to disappear and HomePage to load
      await tester.pumpAndSettle();

      // Verify navigation to HomePage
      expect(find.text('List of Friends:'), findsOneWidget); // Adjust as per your HomePage UI

      // Locate and press the 'Add Friend Manually' button
      final addFriendButton = find.widgetWithText(ElevatedButton, 'Add Friend Manually');
      expect(addFriendButton, findsOneWidget);
      await tester.tap(addFriendButton);
      await tester.pumpAndSettle(); // Wait for the dialog to appear

      // Enter the phone number in the dialog
      final phoneTextField = find.byType(TextField);
      expect(phoneTextField, findsOneWidget);
      await tester.enterText(phoneTextField, '01061952782');
      await tester.pump(); // Trigger the UI update

      // Locate and press the 'Add' button to add the friend
      final addButton = find.widgetWithText(ElevatedButton, 'Add');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle(); // Wait for Firestore data to load

      // After the friend is added, look for "Hassan" in the friend list
      final friendList = find.byType(ListView);
      expect(friendList, findsOneWidget);

      // Search for 'Hassan' in the list of friends
      final hassanText = find.text('Hassan');
      expect(hassanText, findsOneWidget); // Ensure Hassan is listed

      // Tap on "Hassan" to navigate to their event list
      await tester.tap(hassanText);
      await tester.pumpAndSettle(); // Wait for navigation

      // You can assert something on the next screen (Event List Page)
      final eventListPage = find.byType(MyEventListPage);
      expect(eventListPage, findsOneWidget);



    });
  });
}
