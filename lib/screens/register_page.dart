import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/globals.dart';

class RegisterPage extends StatefulWidget {

  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void signUpUser() async {
    // sh owDialog(context: context, builder: (context)=> Center(child: CircularProgressIndicator()));
    try {
     if(passwordController.text==confirmPasswordController.text){
       final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
           email: emailController.text,
           password: passwordController.text
       );
     }
     else{
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           backgroundColor: Colors.red,
           content: Text("Passwords don't match"),
         ),
       );
     }
     // Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      // Navigator.pop(context);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("No user found for that email"),
          ),
        );

      }

      else if (e.code == "email-already-in-use"){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(

            backgroundColor: Colors.red,
            content: Text("This email already exist. Try to use another"),
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
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const SizedBox(height: 20,),

                const Icon(Icons.phone_iphone_outlined,size: 100,),

                const SizedBox(height: 75,),

                Text('HELLO FRESH!',style: kanitStyle.copyWith(fontSize: 36,color: Colors.grey[700])),


                const SizedBox(height: 15,),

                Text('Welcome to our app , newbie!',style: kanitStyle.copyWith(fontSize: 20,color: Colors.grey[700])),

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
                      child: TextFormField(
                          keyboardType: TextInputType.emailAddress,

                          controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: kanitStyle,

                          border: InputBorder.none,
                        ),
                          validator: (email) {
                            if (email != null && !EmailValidator.validate(email) ) {
                              return "Enter valid email!";
                            }
                            else {
                              return null;
                            }
                          }
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
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,

                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          hintStyle: kanitStyle,

                          border: InputBorder.none,
                        ),
                        validator: (value){
                          if(value!=null && value.length<8){
                            return "Password must be 8 chars";
                          }
                          else{
                            return null;
                          }
                        },
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
                      child:  TextFormField(
                        keyboardType: TextInputType.visiblePassword,

                        obscureText: true,

                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: kanitStyle,


                          border: InputBorder.none,
                        ),
                        validator: (value){
                          if(value!=null && (confirmPasswordController.text!=passwordController.text)){
                            return "Passwords must be same!";
                          }
                          else if (passwordController.text == ""){
                            return "Passwords must be same!";


                          }
                          else{
                            return null;
                          }
                        },
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
                    onPressed: (){
                      final isValidForm = _formKey.currentState!.validate();
                      if(isValidForm){
                        signUpUser();
                      }

                    },
                    child: Text('Sign Up',style: kanitStyle.copyWith(color: Colors.white,fontSize: 20)),

                  ),
                ),

                const SizedBox(height: 20,),



                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      'Are you a member? ',
                      style: kanitStyle.copyWith(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: widget.onTap,
                      child: Text(
                          'Sign in',style: kanitStyle.copyWith(fontSize: 16,color: Colors.blue)
                      ),
                    ),
                  ],

                ),


              ],
            ),
          ),
        ),
      ),
    );

  }
}

