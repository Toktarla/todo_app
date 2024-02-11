import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesetup/mixins/focus_node_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/globals.dart';

class RegisterPage extends StatefulWidget with FocusNodeMixin {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // Text Controllers
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Validator
  final _formKey = GlobalKey<FormState>();

  late FocusNode emailFocusNode;
  late FocusNode fullNameFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    fullNameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    fullNameFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void signUpUser() async {
    try {
      if (passwordController.text == confirmPasswordController.text) {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        User? user = credential.user;
        await user?.updateDisplayName(fullNameController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Passwords don't match"),
          ),
        );
      }
      context.go('/verify-email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("No user found for that email"),
          ),
        );
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("This email already exists. Try another."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Icon(
                  Icons.phone_iphone_outlined,
                  size: 100,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text('HELLO FRESH!',
                    style: kanitStyle.copyWith(
                        fontSize: 36, color: Colors.grey[700])),
                const SizedBox(
                  height: 15,
                ),
                Text('Welcome to our app, newbie!',
                    style: kanitStyle.copyWith(
                        fontSize: 20, color: Colors.grey[700])),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    // Email TextFormField
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
                        focusNode: emailFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          widget.fieldFocusChange(
                              context, emailFocusNode, fullNameFocusNode);
                        },
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: kanitStyle,
                          border: InputBorder.none,
                        ),
                        validator: (email) {
                          if (email != null &&
                              !EmailValidator.validate(email)) {
                            return "Enter a valid email!";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    // Full Name TextFormField
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: fullNameController,
                        focusNode: fullNameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          widget.fieldFocusChange(
                              context, fullNameFocusNode, passwordFocusNode);
                        },
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: kanitStyle,
                          border: InputBorder.none,
                        ),
                        validator: (fullName) {
                          final namePattern =
                              RegExp(r'^[A-Z][a-z]+\s[A-Z][a-z]+$');
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
                ),
                const SizedBox(
                  height: 7,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    // New Password TextFormField
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
                        focusNode: passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          widget.fieldFocusChange(context, passwordFocusNode,
                              confirmPasswordFocusNode);
                        },
                        obscureText: true,
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
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    // Confirm Password TextFormField
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          confirmPasswordFocusNode.unfocus();
                          final isValidForm = _formKey.currentState!.validate();
                          if (isValidForm) {
                            signUpUser();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: kanitStyle,
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value != null &&
                              (confirmPasswordController.text !=
                                  passwordController.text)) {
                            return "Passwords must match!";
                          } else if (passwordController.text == "") {
                            return "Passwords must match!";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.purple[800],
                  ),
                  child: TextButton(
                    onPressed: () {
                      confirmPasswordFocusNode.unfocus();
                      final isValidForm = _formKey.currentState!.validate();
                      if (isValidForm) {
                        signUpUser();
                      }
                    },
                    child: Text('Sign Up',
                        style: kanitStyle.copyWith(
                            color: Colors.white, fontSize: 20)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Are you a member? ',
                      style: kanitStyle.copyWith(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Login Page
                        context.go('/login');
                      },
                      child: Text('Sign in',
                          style: kanitStyle.copyWith(
                              fontSize: 16, color: Colors.blue)),
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
