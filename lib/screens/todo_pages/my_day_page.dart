import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasesetup/widgets/task_list.dart';
import 'package:firebasesetup/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class MyDayPage extends StatelessWidget {
  final String todayDate;
  final String title;
  const MyDayPage({Key? key, required this.todayDate, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath = 'https://i.pinimg.com/736x/92/8e/fd/928efdcef393453dcd0d2d0ee86e4d17.jpg';
    final taskController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/myday_image.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomAppBar(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title,style: kanitStyle.copyWith(color: Colors.white,fontSize: 30),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(todayDate,style: kanitStyle.copyWith(color: Colors.white,fontSize: 20)),
            ),
            const SizedBox(height: 20,),
            const TaskList(),



          ],
        ),
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
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: kanitStyle.copyWith(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      String taskTitle = taskController.text;
                      if (taskTitle.isNotEmpty) {
                        await FirebaseFirestore.instance.collection('tasks').add({
                          'title': taskTitle,
                          'titleList': [],
                          'completed': false
                        });

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Create Task',
                      style: kanitStyle.copyWith(color: Colors.pink),  ),
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


