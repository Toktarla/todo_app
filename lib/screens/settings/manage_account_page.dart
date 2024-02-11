import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/theme_cubit.dart';
import '../../utils/globals.dart';


class ManageAccountPage extends StatelessWidget {

  const ManageAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  context.go('/');
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String?>(
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
                            radius: 35,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          user?.displayName ?? "No Display Name",
                          style: kanitStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.keyboard_arrow_up),
                      ],
                    ),
                    Text(
                      user?.email ?? "No Email",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      context.go('/');
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                height: 10,
              ),

              ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  context.go('/login');



                },
                leading: const Icon(Icons.keyboard_double_arrow_left_outlined,color: Colors.red,),
                title: Text('SIGN OUT',style: kanitStyle),
              ),
              ListTile(
                onTap: (){
                  context.go('/settings');
                },
                leading: const Icon(Icons.settings),
                title: Text('Change credentials of user',style: kanitStyle,),
              ),
              ListTile(
                onTap: (){
                  context.read<ThemeCubit>().toggleTheme();
                },
                leading: context.read<ThemeCubit>().state.brightness == Brightness.light
                    ? Icon(Icons.light_mode_rounded,color: Theme.of(context).iconTheme.color,)
                    : Icon(Icons.dark_mode_rounded,color: Theme.of(context).iconTheme.color),
                title: Text('Change theme',style: kanitStyle,),

              )



            ],
          ),
        ),
      ),
    );
  }
}
