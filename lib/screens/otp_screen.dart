import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'home_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen(
      {Key? key,
      required this.username,
      required this.verificationId,
      required this.name,
      required this.occupation,
      required this.phone})
      : super(key: key);

  final String verificationId;
  final String name;
  final String username;
  final String occupation;
  final String phone;

  @override
  Widget build(BuildContext context) {
    String _otpCode = "";
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OtpTextField(
                  numberOfFields: 6,
                  onCodeChanged: (code) {
                    _otpCode += code;
                  }),
              ElevatedButton(
                  onPressed: () async {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: _otpCode);
                    try {
                      print(_otpCode);
                      await _auth.signInWithCredential(credential);
                      User currUser = await _auth.currentUser!!;
                      final document = await _firestore
                          .collection("users")
                          .doc(currUser.uid);
                      final snapshot = await document.get();

                      if (!snapshot.exists) {
                        document.set({
                          "name": name,
                          "username": username,
                          "occupation": occupation,
                          "phone": phone
                        });
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    } catch (e) {
                      print("Couldn't sign in " + e.toString());
                    }
                  },
                  child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
