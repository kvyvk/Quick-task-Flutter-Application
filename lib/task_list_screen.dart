import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'add_task_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// TaskListScreen widget for displaying a list of tasks
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // List of tasks, loading state, and error message
  List<ParseObject> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch tasks when the screen initializes
    _fetchTasks();
  }

  // Method to fetch tasks from the backend
  Future<void> _fetchTasks() async {
    try {
      QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(ParseObject('Task'))
        ..orderByDescending('createdAt');
      final response = await queryBuilder.query();

      if (response.success) {
        setState(() {
          _tasks = response.results as List<ParseObject>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.error!.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
      }
    } catch (e) {
      // Handle query errors
      print('Fetch Tasks Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch tasks. Please try again.')));
    }
  }

  // Method to safely get the due date from a task
  DateTime? _safeGetDueDate(ParseObject task) {
    final dueDate = task.get<DateTime>('dueDate');
    if (dueDate != null) {
      return dueDate;
    } else {
      return DateTime.now();
    }
  }

  // Method to toggle the completion status of a task
  Future<void> _toggleTaskStatus(int index) async {
    try {
      final task = _tasks[index];
      task.set('isCompleted', !(task.get('isCompleted') ?? false));
      final response = await task.save();

      if (response.success) {
        setState(() {
          _tasks[index] = task;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
      }
    } catch (e) {
      // Handle update errors
      print('Toggle Task Status Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to toggle task status. Please try again.')));
    }
  }

  // Method to update a task
  Future<void> _updateTask(int index) async {
    final task = _tasks[index];
    TextEditingController _titleController = TextEditingController(text: task.get<String>('title'));
    DateTime? _dueDate = _safeGetDueDate(task);

    try {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text('Due Date: ${_dueDate?.toLocal()}'),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _dueDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null && selectedDate != _dueDate) {
                          setState(() {
                            _dueDate = selectedDate;
                          });
                        }
                      },
                      child: Text('Select Date'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  task.set('title', _titleController.text);
                  task.set('dueDate', _dueDate);

                  final response = await task.save();

                  if (response.success) {
                    setState(() {
                      _tasks[index] = task;
                    });
                    Navigator.of(context).pop();
                  } else {
                    throw response.error!.message;
                  }
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle update task errors
      print('Update Task Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update task. Please try again.')));
    }
  }

  // Method to delete a task
  Future<void> _deleteTask(int index) async {
    try {
      final task = _tasks[index];
      final response = await task.delete();

      if (response.success) {
        setState(() {
          _tasks.removeAt(index);
        });
      } else {
        throw response.error!.message;
      }
    } catch (e) {
      // Handle delete task errors
      print('Delete Task Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete task. Please try again.')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quick Tasks List',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey, // Set your desired background color
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : _tasks.isEmpty
          ? Center(child: Text('No tasks available.'))
          : SingleChildScrollView(
        child: Center(
          child: DataTable(
            columnSpacing: 100.0,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            dataTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            columns: [
              DataColumn(label: Text('Task Title')),
              DataColumn(label: Text('Due Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _tasks
                .asMap()
                .entries
                .map(
                  (entry) => DataRow(
                color: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                    }
                    return entry.key.isEven ? Colors.grey[200]! : Colors.white;
                  },
                ),
                cells: [
                  DataCell(Text(entry.value.get<String>('title') ?? 'No Title')),
                  DataCell(Text(
                      entry.value.get<DateTime>('dueDate')?.toLocal().toString() ?? 'No Date'
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _updateTask(entry.key);
                        },
                        tooltip: 'Edit Task',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteTask(entry.key);
                        },
                        tooltip: 'Delete Task',
                      ),
                      Checkbox(
                        value: entry.value.get<bool>('isCompleted') ?? false,
                        onChanged: (newValue) {
                          _toggleTaskStatus(entry.key);
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        splashRadius: 16,
                      ),
                      // Display status text based on checkbox value
                      Text(
                        entry.value.get<bool>('isCompleted') ?? false ? 'Completed' : 'Incomplete',
                        style: TextStyle(
                          color: entry.value.get<bool>('isCompleted') ?? false ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to the screen to add a new task
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          // After adding a task, fetch tasks again to update the table
          _fetchTasks();
        },
        label: Text('Add Task', style: TextStyle(color: Colors.white)), // Set text color
        icon: Icon(Icons.add),
        backgroundColor: Colors.orange, // Set your desired background color
      ),
    );
  }

}

