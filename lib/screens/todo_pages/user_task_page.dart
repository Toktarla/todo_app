import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesetup/utils/task_id_generator.dart';
import 'package:firebasesetup/widgets/task_list.dart';
import 'package:firebasesetup/widgets/user_task_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/globals.dart';

class UserTaskPage extends StatelessWidget {
  final String taskId;
  final String title;
  const UserTaskPage({Key? key, required this.taskId, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomAppBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title,style: kanitStyle.copyWith(color: Colors.white,fontSize: 30),),
          ),

          const SizedBox(height: 20,),
          UserTaskList(taskId: taskId),



        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a Task',
        backgroundColor: Colors.cyan,
        elevation: 0,
        shape: const CircleBorder(),
        isExtended: true,
        child: const Icon(Icons.add,size: 40,),
        onPressed: () {
          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          final hintText = 'Add a task';

          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Create Task',
                  style: kanitStyle.copyWith(color: Colors.black),
                ),
                content: TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    labelText: 'Task',
                    hintText: hintText,
                    hintStyle: kanitStyle.copyWith(color: Colors.black),

                    border: const OutlineInputBorder(),
                  ),
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
                      String newTaskTitle = taskController.text;
                      Navigator.of(context).pop();

                      if (newTaskTitle.isNotEmpty) {
                        var newTask = {
                          'title': newTaskTitle,
                          'completed': false,
                          'taskID' : TaskIDGenerator.generateTaskID(),

                        };

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('lists')
                            .doc(taskId)
                            .update({'listTasks': FieldValue.arrayUnion([newTask])});
                      }
                    },
                    child: Text(
                      'Add Task',
                      style: TextStyle(color: Colors.pink),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      // Your custom app bar design
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // To avoid overlapping status bar

      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const Spacer(),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    // Handle onTap action for PopupMenuItem
                  },
                  child: const Text('Archive settings'),
                ),
                value: 'Archive settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
