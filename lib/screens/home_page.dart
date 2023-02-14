import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesetup/utils/globals.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: TextButton(
          onPressed: signOut,
          child: Text("Sign Out",style: kanitStyle.copyWith(fontSize: 12),),


         ),
      ),
      body: Center(
        child: Text(
          'You logged in succesfully as\n'
              '${user!.email}',
          style: kanitStyle.copyWith(color: Colors.lightBlue,fontSize: 36),
          textAlign: TextAlign.center,
        ),

      ),

    );
  }

  Future<void> signOut() async {

    await FirebaseAuth.instance.signOut();

  }
}
