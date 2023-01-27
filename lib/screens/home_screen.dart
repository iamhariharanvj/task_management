import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manage_io/screens/tasks_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? currUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context, builder: (context) => SearchPopup());
              },
              icon: Icon(Icons.add_moderator)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TaskScreen()));
              },
              icon: Icon(Icons.add))
        ],
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
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 200,
                            color: Colors.green,
                            child: FutureBuilder(
                                future: _firestore
                                    .collection("users")
                                    .doc(snapshot.data?.docs[index].id)
                                    .get(),
                                builder: (cntext, snpshot) {
                                  print("Debugging ID " +
                                      snpshot.data!.id.toString());
                                  if (snpshot.hasData) {
                                    return Container(
                                      child:
                                          Text(snpshot.data!.data().toString()),
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

class SearchPopup extends StatefulWidget {
  SearchPopup({Key? key}) : super(key: key);

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  final _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: "Search"),
          onChanged: (text) {
            setState(() {
              _searchText = text;
            });
          },
        ),
        Expanded(
            child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('occupation',
                  isGreaterThanOrEqualTo: _searchText,
                  isLessThan: _searchText + 'z')
              .get(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            if (snapshot.data!.docs.length == 0) {
              return Text("No Users found");
            } else {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final employeeUID = snapshot.data!.docs[index].id;

                  final name = data["name"] != null ? data["name"] : "name";
                  final occupation = data["occupation"] != null
                      ? data["occupation"]
                      : "occupation";

                  return Container(
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontSize: 24),
                            ),
                            Text(occupation)
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              launch("tel:" + data["phone"].toString());
                            },
                            icon: Icon(Icons.call)),
                        IconButton(
                            onPressed: () async {
                              print(employeeUID);
                              final doc = await _firestore
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid);

                              await doc
                                  .collection("employees")
                                  .doc(employeeUID)
                                  .set({"name": name});
                            },
                            icon: Icon(Icons.person_add))
                      ],
                    ),

                    // return ListTile(
                    //   title: Text(name),
                    //   subtitle: Text(occupation),

                    // other fields
                  );
                },
              );
            }
          },
        ))
      ],
    );
  }
}
