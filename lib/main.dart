import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'auth_screen.dart'; // Import the AuthScreen widget
import 'task_list_screen.dart'; // Import the TaskListScreen widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Parse Server configuration
  final keyApplicationId = ''; // Add your Parse Server Application ID
  final keyClientKey = ''; // Add your Parse Server Client Key
  final keyParseServerUrl = 'https://parseapi.back4app.com'; // Add your Parse Server URL

  // Initialize Parse SDK
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  // Run the application
  runApp(MyApp());
}

// MyApp class, which represents the root of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask App', // Set the title of the application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color theme
      ),
      home: AuthScreen(), // Set the initial route to the AuthScreen
      routes: {
        '/tasks': (context) => TaskListScreen(), // Define a named route for the TaskListScreen
      },
    );
  }
}