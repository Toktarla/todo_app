import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasesetup/widgets/task_list.dart';
import 'package:firebasesetup/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


class MyDayPage extends StatelessWidget {
  final String todayDate;
  final String title;
  final String userUid;

  const MyDayPage({Key? key, required this.todayDate, required this.title, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath = 'https://i.pinimg.com/736x/92/8e/fd/928efdcef393453dcd0d2d0ee86e4d17.jpg';
    final taskController = TextEditingController();
    final dateController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/important.jpg'),
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
            TaskList(listTitle: title, userUid: userUid),
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
          DateTime selectedDate = DateTime.now(); // Default to today's date

          // Show a dialog with options to set due date
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Create Task',
                  style: kanitStyle.copyWith(color: Colors.black),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        hintText: hintText,
                        hintStyle: kanitStyle.copyWith(color: Colors.black),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Pick a due date
                        final pickedDate = await showDialog<DateTime>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Pick Due Date',
                                style: kanitStyle.copyWith(color: Colors.black),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(DateTime.now());
                                    },
                                    child: Text('Today'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(DateTime.now().add(Duration(days: 1)));
                                    },
                                    child: Text('Tomorrow'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                                        lastDate: DateTime.now().add(Duration(days: 365)),
                                      );
                                      if (pickedDate != null) {
                                        Navigator.of(context).pop(pickedDate);
                                      }
                                    },
                                    child: Text('Pick a Date'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                          Navigator.of(context).pop();
                          _addTask(taskController.text, selectedDate);
                        }
                      },
                      child: Text('Pick Due Date'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),


    );
  }

  void _addTask(String taskTitle, DateTime dueDate) async {
    if (taskTitle.isNotEmpty) {
      var task = {
        'title': taskTitle,
        'completed': false,
        'date': dueDate.toIso8601String(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection("ready_lists")
          .doc(title)
          .update({
        'listTasks': FieldValue.arrayUnion([task])
      });
    }
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