import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasesetup/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? userId = user?.uid;

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

    Future<void> uploadProfilePicture() async {
      print("HEERE");
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png'
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        File pickedFile = File(file.path ?? '');

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child(user?.uid ?? 'default')
            .child('profile_pic.jpg');

        UploadTask uploadTask = ref.putFile(pickedFile);

        try {
          await uploadTask.whenComplete(() async {
            String imageURL = await ref.getDownloadURL();

            if (userId != null) {
              await FirebaseFirestore.instance
                  .collection('users_pfp')
                  .doc(userId)
                  .set({'link': imageURL});
            }



            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Profile picture updated successfully'),
              ),
            );
          });
        } catch (error) {
          print(error);
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.go('/manage-account');
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          "Modify user crediantials",
          style: kanitStyle.copyWith(fontSize: 16, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 30,
              ),
          Center(
            child: FutureBuilder<String?>(
              future: getUserProfilePictureLink(userId),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String? imagePath = snapshot.data;
                  return CircleAvatar(
                    backgroundImage: NetworkImage(imagePath ?? defaultImagePath),
                    radius: 50,
                  );
                }
              },
            ),
          ),

          const SizedBox(
                height: 15,
              ),
              Center(
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                          onPressed: uploadProfilePicture,
                          child: Text(
                            "Upload File",
                            style: kanitStyle,
                          )))),
              const SizedBox(
                height: 10,
              ),

              // Email
              Text(
                'Change user email',
                style: kanitStyle.copyWith(color: Colors.black54, fontSize: 18),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                      onTap: () {
                        emailController.selection = TextSelection.fromPosition(
                          TextPosition(offset: emailController.text.length),
                        );
                      },
                      onFieldSubmitted: (newEmail) async {
                        if (newEmail != user?.email) {
                          try {
                            print(newEmail);
                            await user
                                ?.updateEmail(newEmail ?? '')
                                .onError((error, stackTrace) {
                              print("=========================");

                              print(error);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Email updated successfully'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Failed to update email'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('It is the same email'),
                            ),
                          );
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Current : ${user?.email ?? "No email"}',
                        hintStyle: kanitStyle,
                        border: InputBorder.none,
                      ),
                      validator: (email) {
                        if (email != null && !EmailValidator.validate(email)) {
                          return "Enter valid email!";
                        } else {
                          return null;
                        }
                      }),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              // Display Name
              Text(
                'Change user display name',
                style: kanitStyle.copyWith(color: Colors.black54, fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    onFieldSubmitted: (newDisplayName) async {
                      if (newDisplayName != user?.displayName) {
                        try {
                          await user?.updateDisplayName(newDisplayName ?? '');
                          ScaffoldMessenger.of(context).clearSnackBars();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content:
                                  Text('Display name updated successfully'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).clearSnackBars();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Failed to update display name'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('It is the same display name'),
                          ),
                        );
                      }
                    },
                    keyboardType: TextInputType.name,
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText:
                          'Current : ${user?.displayName ?? "No display name"}',
                      hintStyle: kanitStyle,
                      border: InputBorder.none,
                    ),
                    validator: (fullName) {
                      final namePattern = RegExp(r'^[A-Z][a-z]+\s[A-Z][a-z]+$');
                      if (fullName == null || fullName.isEmpty) {
                        return 'Please enter your full name';
                      } else if (!namePattern.hasMatch(fullName.trim())) {
                        return 'Please enter a valid full name like "Toktar Sultan"';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Password
              Text(
                'Change user password',
                style: kanitStyle.copyWith(color: Colors.black54, fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                      // Inside the TextFormField for changing password
                      onFieldSubmitted: (newPassword) async {
                        if (newPassword != null && newPassword.length >= 8) {
                          try {
                            await user?.updatePassword(newPassword);
                            ScaffoldMessenger.of(context).clearSnackBars();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Password updated successfully'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).clearSnackBars();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Failed to update password'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                  'Password must be at least 8 characters'),
                            ),
                          );
                        }
                      },
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'New Password',
                        hintStyle: kanitStyle,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value != null && value.length < 8) {
                          return "Password must be 8 chars";
                        } else {
                          return null;
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
