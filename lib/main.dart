import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_programming_project/Models/Database.dart';
import 'firebase_options.dart';
import 'login_page.dart'; // Import LoginPage
import 'register_page.dart'; // Import RegisterPage
import 'FriendGiftListPage.dart'; // Import FriendGiftListPage
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Database


  // Initialize Firebase

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    print('Firebase initialized successfully.');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme for the app
        scaffoldBackgroundColor: Colors.black, // Black background
        primaryColor: Colors.red, // Red as the primary color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Red buttons
            foregroundColor: Colors.white, // White text on buttons
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // White body text (large)
          bodyMedium: TextStyle(color: Colors.white), // White body text (medium)
          bodySmall: TextStyle(color: Colors.white), // White body text (small)
        ),
      ),
      initialRoute: '/login', // Initial route set to '/login'
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),

        // Add other pages as needed
      },
      debugShowCheckedModeBanner: false, // Disable debug banner
    );
  }
}
