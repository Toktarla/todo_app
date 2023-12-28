import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../utils/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String?> getUserProfilePictureLink(String? userId) async {
    String? profilePicLink;
    try {
      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users_pfp')
          .doc(userId)
          .get();

      if (userProfileSnapshot.exists) {
        profilePicLink = userProfileSnapshot.get('link');
      }
    } catch (e) {
      print('Error fetching user profile picture link: $e');
    }
    return profilePicLink;
  }

  final messageController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  PlatformFile? pickedFile;
  String? downloadUrl;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final path = "files/${pickedFile!.name}";
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() {});
    downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      uploadTask = null;
    });
  }

  String imagePath =
      'https://cdn1.iconfinder.com/data/icons/instagram-ui-colored/48/JD-18-512.png';

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  int taskCount = 0;

  List<Map<String, dynamic>> myListData = [
    {
      'title': 'My Day',
      'trailing': 0,
      'icon': Icons.light_mode_outlined,
      'color': Colors.blueGrey
    },
    {
      'title': 'Important',
      'trailing': 1,
      'icon': Icons.star_border,
      'color': Colors.pink
    },
    {
      'title': 'Planned',
      'trailing': 0,
      'icon': Icons.calendar_month_outlined,
      'color': Colors.cyan
    },
    {
      'title': 'Assigned to me',
      'trailing': 0,
      'icon': Icons.person,
      'color': Colors.greenAccent
    },
    {
      'title': 'Flagged email',
      'trailing': 0,
      'icon': Icons.flag,
      'color': Colors.red
    },
    {
      'title': 'Tasks',
      'trailing': 0,
      'icon': Icons.task_alt,
      'color': Colors.blueAccent
    },
  ];

  List<Map<String, dynamic>> userList = [
    {
      'title': 'Toktar',
      'trailing': 0,
      'icon': Icons.list,
      'color': Colors.blueAccent
    },
    {
      'title': 'Task',
      'trailing': 1,
      'icon': Icons.list,
      'color': Colors.blueAccent
    },
    {
      'title': 'Toktar',
      'trailing': 0,
      'icon': Icons.list,
      'color': Colors.blueAccent
    },
    {
      'title': 'Toktar',
      'trailing': 0,
      'icon': Icons.list,
      'color': Colors.blueAccent
    },
    {
      'title': 'Toktar',
      'trailing': 0,
      'icon': Icons.list,
      'color': Colors.blueAccent
    },
  ];

  Future<void> _createList() async {
    String newListTitle = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New List'),
          content: TextField(
            onChanged: (value) {
              newListTitle = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter list title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newListTitle.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('lists')
                      .add({
                    'listName': newListTitle,
                    'listTasks': [],
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create List'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                context.go('/manage-account');
              },
              leading: FutureBuilder<String?>(
                future: getUserProfilePictureLink(user?.uid),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String? imagePath = snapshot.data;
                    return CircleAvatar(
                      backgroundImage:
                          NetworkImage(imagePath ?? defaultImagePath),
                    );
                  }
                },
              ),
              title: Row(
                children: [
                  Text(
                    user?.displayName ?? "No Display Name",
                    style: kanitStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.keyboard_arrow_down)
                ],
              ),
              subtitle: Text(user?.email ?? "No email"),
              trailing: SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    print("Search Icon");
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 45,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            final int taskCount =
                                snapshot.data?.docs.length ?? 0;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: myListData.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = myListData[index];
                                return ListTile(
                                  leading:
                                      Icon(item['icon'], color: item['color']),
                                  title: Text(item['title']),
                                  trailing: Text(index == 0 && taskCount != 0
                                      ? taskCount.toString()
                                      : ''),
                                  onTap: () {
                                    context.go('/myday', extra: {
                                      'title': item['title'],
                                      'todayDate': DateFormat('EEEE, MMMM d')
                                          .format(DateTime.now()),
                                    });
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                      const Divider(
                        height: 20,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('lists')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No lists found.'));
                          } else {
                            final List<DocumentSnapshot> lists =
                                snapshot.data!.docs;
                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: lists.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> item =
                                    lists[index].data() as Map<String, dynamic>;
                                final list = lists[index].id;

                                // Count the number of tasks
                                final List<dynamic> listTasks =
                                    item['listTasks'] ?? [];
                                final int taskCount = listTasks.length;

                                return ListTile(
                                  title: Text(item['listName']),
                                  trailing: Text(taskCount == 0
                                      ? ''
                                      : taskCount
                                          .toString()), // Display the task count
                                  leading: const Icon(
                                    Icons.list,
                                    color: Colors.blueAccent,
                                  ),
                                  onTap: () {
                                    context.go('/user-task', extra: {
                                      'title': item['listName'],
                                      'taskId': list,
                                    });
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: _createList,
              title: Text(
                'New list',
                style: kanitStyle,
              ),
              leading: const Icon(Icons.add),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.create_new_folder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
