import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/globals.dart';
class LoginPage extends StatefulWidget {

  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signInUser() async {
    // showDialog(context: context, builder: (context)=> Center(child: CircularProgressIndicator()));
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
      // Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("No user found for that email"),
          ),
        );
      }
      else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(

            backgroundColor: Colors.red,
            content: Text("Wrong password provided for that user"),
          ),
        );
      }

    }





  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20,),

              const Icon(Icons.phone_android,size: 100,),

              const SizedBox(height: 75,),

              Text('HELLO AGAIN!',style: kanitStyle.copyWith(fontSize: 36,color: Colors.grey[700])),


              const SizedBox(height: 15,),

              Text('Welcome back , you have been missed',style: kanitStyle.copyWith(fontSize: 20,color: Colors.grey[700])),

              const SizedBox(height: 30,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: kanitStyle,

                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 7,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child:  TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: kanitStyle,



                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              Container(
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.purple[800],


                ),
                child: TextButton(
                  onPressed: signInUser,
                  child: Text('Sign In',style: kanitStyle.copyWith(color: Colors.white,fontSize: 20)),

                ),
              ),

              const SizedBox(height: 20,),



              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    'Not a member? ',
                    style: kanitStyle.copyWith(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: widget.onTap,
                    child: Text(
                        'Register now',style: kanitStyle.copyWith(fontSize: 16,color: Colors.blue)
                    ),
                  ),
                ],

              ),







            ],
          ),
        ),
      ),

    );

  }
}

