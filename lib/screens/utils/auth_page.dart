import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesetup/screens/home_page.dart';
import 'package:firebasesetup/screens/utils/log_or_reg_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return HomePage();
          }
          else{

            return LoginOrRegisterPage();

          }
          },

      ),


    );
  }
}
