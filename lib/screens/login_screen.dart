import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manage_io/screens/otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key, required this.name}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _LoginScreen(name: name),
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen({Key? key, required this.name}) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    String _name = '';
    String _occupation = '';
    String _phone = '';
    void sendOtp() async {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91" + _phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            print(e);
          },
          codeSent: (String verificationId, int? forceResending) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtpScreen(
                          name: name,
                          username: _name,
                          occupation: _occupation,
                          phone: _phone,
                          verificationId: verificationId,
                        )));
          },
          codeAutoRetrievalTimeout: (String timeout) {});
    }

    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Enter your Name"),
              onChanged: (text) {
                _name = text;
              },
            ),
            TextField(
              decoration: InputDecoration(hintText: "Enter your occupation"),
              onChanged: (occupation) {
                _occupation = occupation;
              },
            ),
            TextField(
              decoration: InputDecoration(hintText: "Enter your phone number"),
              onChanged: (phone) {
                _phone = phone;
              },
              maxLength: 10,
            ),
            ElevatedButton(onPressed: sendOtp, child: Text("Continue"))
          ],
        ),
      ),
    );
  }
}
