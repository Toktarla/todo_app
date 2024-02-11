import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/globals.dart';

class UserTaskList extends StatelessWidget {
  final String taskId;

  const UserTaskList({required this.taskId});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('lists')
          .doc(taskId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var listData = snapshot.data?.data() as Map<String, dynamic>?;

        List listTasks = listData?['listTasks'] ?? [];

        List<Map<String, dynamic>> completedTasks = listTasks
            .where((task) => task['completed'] == true)
            .toList()
            .cast<Map<String, dynamic>>();

        List<Map<String, dynamic>> uncompletedTasks = listTasks
            .where((task) => task['completed'] == false)
            .toList()
            .cast<Map<String, dynamic>>();

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uncompletedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uncompletedTasks
                        .map((task) => _buildTaskTile(context, task))
                        .toList(),
                  ),
                if (completedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Completed    ${completedTasks.length}',
                          style: TextStyle(color: Colors.white),
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

  Widget _buildTaskTile(BuildContext context, Map<String, dynamic> task) {
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
          title: Text(
            task['title'],
            style: kanitStyle.copyWith(
              color: Colors.grey,
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

  Widget _buildCompletedTaskTile(
      BuildContext context, Map<String, dynamic> task) {
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

                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('lists')
        .doc(taskId)
        .update({
      'listTasks': FieldValue.arrayRemove([task]),
    });
  }

  void _showEditTaskDialog(BuildContext context, Map<String, dynamic> task) {
    TextEditingController editTaskController =
        TextEditingController(text: task['title']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Task',
            style: TextStyle(color: Colors.black),
          ),
          content: TextField(
            controller: editTaskController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Task',
              hintText: 'Edit Task',
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                String editedTitle = editTaskController.text;
                Navigator.of(context).pop();

                if (editedTitle.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('lists')
                      .doc(taskId)
                      .update({
                    'listTasks': FieldValue.arrayRemove([task])
                  });

                  task['title'] = editedTitle;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('lists')
                      .doc(taskId)
                      .update({
                    'listTasks': FieldValue.arrayUnion([task])
                  });
                }
              },
              child: Text(
                'Update Task',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }

  void _completeTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('lists')
        .doc(taskId)
        .update({
      'listTasks': FieldValue.arrayRemove([task]), // Remove the task
    });

    task['completed'] = true;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('lists')
        .doc(taskId)
        .update({
      'listTasks': FieldValue.arrayUnion([task]), // Add the updated task back
    });
  }

  void _uncompleteTask(Map<String, dynamic> task) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('lists')
        .doc(taskId)
        .update({
      'listTasks': FieldValue.arrayRemove([task]),
    });

    task['completed'] = false;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('lists')
        .doc(taskId)
        .update({
      'listTasks': FieldValue.arrayUnion([task]),
    });
  }
}
