import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/globals.dart';

class TaskList extends StatelessWidget {
  const TaskList();
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var tasks = snapshot.data!.docs;

        List<DocumentSnapshot> completedTasks = tasks
            .where((task) => task['completed'] == true)
            .toList();

        List<DocumentSnapshot> uncompletedTasks = tasks
            .where((task) => task['completed'] == false)
            .toList();

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
                      ...uncompletedTasks.map((task) => _buildTaskTile(context, task)).toList(),
                    ],
                  ),

                // Completed tasks
                if (completedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
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
                      ...completedTasks.map((task) => _buildCompletedTaskTile(context, task)).toList(),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(BuildContext context, DocumentSnapshot task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
      },
      child: InkWell(
        onTap: () {
          _completeTask(task.id);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(33, 33, 33, 1).withOpacity(0.9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ListTile(
            key: ValueKey(task.id),
            title: Text(task['title'], style: kanitStyle.copyWith(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    _showEditTaskDialog(context, task.id, task['title']);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.indigo),
                  onPressed: () {
                    // Handle star action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTaskTile(BuildContext context, DocumentSnapshot task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
      },
      child: InkWell(
        onTap: () {
          _uncompleteTask(task.id);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(33, 33, 33, 1).withOpacity(0.9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ListTile(
            key: ValueKey(task.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    _showEditTaskDialog(context, task.id, task['title']);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.indigo),
                  onPressed: () {
                    // Handle star action
                  },
                ),
              ],
            ),
            title: Text(
              task['title'],
              style: kanitStyle.copyWith(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, String taskId, String currentTitle) {
    TextEditingController editTaskController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Task',
            style: kanitStyle.copyWith(color: Colors.black),
          ),
          content: TextField(
            controller: editTaskController,
            style: kanitStyle.copyWith(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Task',
              hintText: 'Edit Task',
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
                String editedTitle = editTaskController.text;
                Navigator.of(context).pop();

                if (editedTitle.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .update({'title': editedTitle});
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
  }

  void _completeTask(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'completed': true});
  }

  void _uncompleteTask(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'completed': false});
  }
}
