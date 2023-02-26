import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesetup/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'messages_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: TextButton(
          onPressed: signOut,
          child: Text("Sign Out",style: kanitStyle.copyWith(fontSize: 12),),


         ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.79,
              child: MessagesScreen(
                email: user!.email,
              ),
            ),


            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.purple[100],
                      hintText: 'message',
                      enabled: true,
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 8.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.purple),
                        borderRadius: new BorderRadius.circular(10),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.purple),
                        borderRadius: new BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {},
                    onSaved: (value) {
                      messageController.text = value!;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    try{
                      if (messageController.text.isNotEmpty) {
                        final docUser = db.collection('Messages').doc();
                        final json =
                        {
                          'message': messageController.text.trim(),
                          'time': DateTime.now(),
                          'email': user!.email,
                        };
                         docUser.set(json);

                        messageController.clear();
                      }
                    }
                    catch (e) {

                      print(e);

                    }

                  },
                  icon: Icon(Icons.send_sharp),
                ),
              ],
            ),

          ],
        ),
      )

    );
  }

  Future<void> signOut() async {

    await FirebaseAuth.instance.signOut();

  }
}
