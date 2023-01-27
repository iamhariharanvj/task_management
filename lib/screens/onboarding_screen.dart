import 'package:flutter/material.dart';

import 'login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _OnBoardingBody()));
  }
}

class _OnBoardingBody extends StatelessWidget {
  const _OnBoardingBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
          children: [
            Text("Welcome to our Application"),
            Text("May we know your name??"),
            TextField(
              decoration: InputDecoration(hintText: "Enter your name"),
              onSubmitted: (text) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(name: text)));
              },
            )
          ],
        ));
  }
}
