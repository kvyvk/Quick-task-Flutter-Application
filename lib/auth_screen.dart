import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:google_fonts/google_fonts.dart';

// AuthScreen widget for handling authentication
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Text editing controllers for email and password fields
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Method to handle user login
  Future<void> _login() async {
    final user = ParseUser(_emailController.text, _passwordController.text, null);
    final response = await user.login();

    // Navigate to the task list screen if login is successful
    if (response.success) {
      Navigator.of(context).pushReplacementNamed('/tasks');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

  // Method to handle user sign up
  Future<void> _signUp() async {
    var user = ParseUser(_emailController.text, _passwordController.text, _emailController.text);
    user.set('username', _emailController.text);
    user.set('email', _emailController.text);

    try {
      await user.signUp();
      // Navigate to the next screen after successful signup
    } catch (e) {
      // Handle signup errors
      print('Sign Up Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up failed. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickTask', style: GoogleFonts.poppins()), // Set app title
        centerTitle: true,
        backgroundColor: Colors.blueGrey, // Set app bar background color
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back!', // Welcome message
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email', // Email text field
                border: OutlineInputBorder(), // Add border
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password', // Password text field
                border: OutlineInputBorder(), // Add border
              ),
              obscureText: true, // Hide password text
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login, // Call _login method on button press
                  child: Text('Login', style: GoogleFonts.poppins()), // Button text
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Button padding
                    backgroundColor: Colors.green, // Button background color
                    foregroundColor: Colors.black, // Button text color
                  ),
                ),
                ElevatedButton(
                  onPressed: _signUp, // Call _signUp method on button press
                  child: Text('Sign Up', style: GoogleFonts.poppins()), // Button text
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Button padding
                    backgroundColor: Colors.indigo, // Button background color
                    foregroundColor: Colors.black, // Button text color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
