import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:intl/intl.dart';

// AddTaskScreen widget for adding a new task
class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Controllers for title and due date
  final TextEditingController _titleController = TextEditingController();
  DateTime _dueDate = DateTime.now();

  // Method to add a new task
  Future<void> _addTask() async {
    // Create a new ParseObject for the task
    final task = ParseObject('Task')
      ..set('title', _titleController.text)
      ..set('dueDate', _dueDate)
      ..set('isCompleted', false);

    // Save the task to the backend
    final response = await task.save();

    // Check if the task was saved successfully
    if (response.success) {
      Navigator.of(context).pop(); // Navigate back to the previous screen
    } else {
      // Show a snackbar with the error message if the task failed to save
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title field
            Text(
              'Task Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Due Date field
            Row(
              children: [
                Text(
                  'Due Date: ${DateFormat('MMM d, yyyy').format(_dueDate.toLocal())}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                // Select Date button
                ElevatedButton(
                  onPressed: () async {
                    // Show date picker dialog
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    // Update due date if a date is selected
                    if (selectedDate != null && selectedDate != _dueDate) {
                      setState(() {
                        _dueDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Style for the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen, // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Button border radius
                    ),
                    elevation: 3, // Button shadow
                    shadowColor: Colors.grey, // Shadow color
                    textStyle: TextStyle(
                      letterSpacing: 1.0, // Adjust text spacing
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Add Task button
            ElevatedButton(
              onPressed: _addTask,
              child: Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Style for the button
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button border radius
                ),
                elevation: 3, // Button shadow
                shadowColor: Colors.grey, // Shadow color
                textStyle: TextStyle(
                  letterSpacing: 1.0, // Adjust text spacing
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
