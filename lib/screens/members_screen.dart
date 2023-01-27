import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<String> uids = [];

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? currUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: Column(children: [
        Expanded(
          child: FutureBuilder(
              future: _firestore
                  .collection("users")
                  .doc(currUser?.uid)
                  .collection("employees")
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    print("Snap Data" + snapshot.data!.docs[0].id.toString());
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Container(
                            child: FutureBuilder(
                                future: _firestore
                                    .collection("users")
                                    .doc(snapshot.data?.docs[index].id)
                                    .get(),
                                builder: (cntext, snpshot) {
                                  if (snpshot.hasData) {
                                    final data = snpshot.data!.data()
                                        as Map<String, dynamic>;
                                    final name = data["name"];
                                    final occupation = data["occupation"];
                                    final phone = data["phone"];

                                    return Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text("Name: ${name}"),
                                              Text("Occupation: ${occupation}"),
                                              Text("Phone: ${phone}"),
                                              SizedBox(
                                                height: 30,
                                              ),
                                            ],
                                          ),
                                          Checkbox(
                                              value: uids
                                                  .contains(snpshot.data!.id),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value!) {
                                                    uids.add(snpshot.data!.id);
                                                  } else {
                                                    uids.remove(
                                                        snpshot.data!.id);
                                                  }
                                                  print(value);
                                                  print("LENGTH: " +
                                                      uids.length.toString());
                                                });
                                              })
                                        ],
                                      ),
                                    );
                                  }
                                  return Container(child: Text("Loading..."));
                                }),
                          );
                        });
                  } else {
                    return Text("Not Succeeeded");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }),
        )
      ]),
    );
  }
}
