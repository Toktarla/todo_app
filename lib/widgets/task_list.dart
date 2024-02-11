import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/globals.dart';

class TaskList extends StatelessWidget {
  final String userUid;
  final String listTitle;

  const TaskList({required this.userUid, required this.listTitle});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('ready_lists')
          .doc(listTitle)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var data = snapshot.data!.data() as Map<String, dynamic>?;

        List<dynamic> tasks = data?['listTasks'] ?? [];

        List<dynamic> completedTasks =
        tasks.where((task) => task['completed'] == true).toList();

        List<dynamic> uncompletedTasks =
        tasks.where((task) => task['completed'] == false).toList();

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Uncompleted tasks
                if (uncompletedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...uncompletedTasks
                          .map((task) => _buildTaskTile(context, task))
                          .toList(),
                    ],
                  ),

                // Completed tasks
                if (completedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Completed    ${completedTasks.length}',
                          style: kanitStyle.copyWith(color: Colors.white),
                        ),
                      ),
                      ...completedTasks
                          .map((task) => _buildCompletedTaskTile(context, task))
                          .toList(),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(BuildContext context, dynamic task) {
    return InkWell(
      onTap: () {
        _completeTask(task);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(33, 33, 33, 1).withOpacity(0.9),
          borderRadius: BorderRadius.circular(7),
        ),
        child: ListTile(
          title: Text(task['title'],
              style: kanitStyle.copyWith(color: Colors.white)),
          subtitle: Text(
            _formatDate(task['date']), // Display formatted date
            style: kanitStyle.copyWith(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.indigo),
                onPressed: () {
                  _showEditTaskDialog(context, task);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.indigo),
                onPressed: () {
                  _deleteTask(task);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTaskTile(BuildContext context, dynamic task) {
    return InkWell(
      onTap: () {
        _uncompleteTask(task);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(33, 33, 33, 1).withOpacity(0.9),
          borderRadius: BorderRadius.circular(7),
        ),
        child: ListTile(
          title: Text(
            task['title'],
            style: kanitStyle.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(
            _formatDate(task['date']),
            style: kanitStyle.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.indigo),
                onPressed: () {
                  _showEditTaskDialog(context, task);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.indigo),
                onPressed: () {
                  _deleteTask(task);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    // Parse ISO 8601 date string and format it
    DateTime date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy').format(date); // Example format: Jan 01, 2023
  }


  void _showEditTaskDialog(BuildContext context, dynamic task) {
    TextEditingController editTaskController =
    TextEditingController(text: task['title']);
    TextEditingController editDateController =
    TextEditingController(text: _formatDate(task['date']));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Task',
                style: kanitStyle.copyWith(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: editTaskController,
                    style: kanitStyle.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Task',
                      hintText: 'Edit Task',
                      hintStyle: kanitStyle.copyWith(color: Colors.black),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: editDateController,
                          style: kanitStyle.copyWith(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Edit Date',
                            hintStyle: kanitStyle.copyWith(color: Colors.black),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 365)),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              editDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: kanitStyle.copyWith(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    String editedTitle = editTaskController.text;
                    String editedDate = editDateController.text;
                    Navigator.of(context).pop();

                    if (editedTitle.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userUid)
                          .collection("ready_lists")
                          .doc(listTitle)
                          .update({
                        'listTasks': FieldValue.arrayRemove([task])
                      });

                      task['title'] = editedTitle;
                      task['date'] = editedDate; // Update date

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userUid)
                          .collection("ready_lists")
                          .doc(listTitle)
                          .update({
                        'listTasks': FieldValue.arrayUnion([task])
                      });
                    }
                  },
                  child: Text(
                    'Update Task',
                    style: kanitStyle.copyWith(color: Colors.pink),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _completeTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection("ready_lists")
        .doc(listTitle)
        .update({
      'listTasks': FieldValue.arrayRemove([
        task
      ]),
    });
    task['completed'] = true;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection("ready_lists")
        .doc(listTitle)
        .update({
      'listTasks': FieldValue.arrayUnion([
        task
      ]),
    });
  }

  void _deleteTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('ready_lists')
        .doc(listTitle)
        .update({
      'listTasks': FieldValue.arrayRemove([task]),
    });
  }

  void _uncompleteTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection("ready_lists")
        .doc(listTitle)
        .update({
      'listTasks': FieldValue.arrayRemove([task]),
    });

    task['completed'] = false;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection("ready_lists")
        .doc(listTitle)
        .update({
      'listTasks': FieldValue.arrayUnion([task]),
    });
  }
}
