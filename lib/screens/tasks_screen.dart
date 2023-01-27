import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Task")),
      body: SafeArea(
        child: SingleChildScrollView(child: TaskForm()),
      ),
    );
  }
}

class TaskForm extends StatelessWidget {
  const TaskForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = "";
    String description = "";
    String amount = "";
    String nhours = "";

    return Container(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Enter title"),
            onChanged: (text) => title = text,
          ),
          TextField(
            maxLines: 8,
            decoration: InputDecoration(hintText: "Description"),
            onChanged: (text) => description = text,
          ),
          TextField(
            maxLines: 1,
            decoration: InputDecoration(hintText: "Amount of Working Hours"),
            onChanged: (text) => nhours = text,
          ),
          TextField(
            maxLines: 1,
            decoration: InputDecoration(hintText: "Payment Amount"),
            onChanged: (text) => amount = text,
          ),
          CaptureImage(
              title: title,
              description: description,
              nhours: nhours,
              amount: amount),
        ],
      ),
    );
  }
}

class CaptureImage extends StatefulWidget {
  const CaptureImage(
      {Key? key,
      required this.title,
      required this.description,
      required this.nhours,
      required this.amount})
      : super(key: key);

  final String title;
  final String description;
  final String nhours;
  final String amount;

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  File? _imageFile;

  Future<void> _pickImage() async {
    XFile? selected = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(selected!.path);
    });
  }

  Future<void> _cropImage() async {
    CroppedFile? cropped =
        await ImageCropper().cropImage(sourcePath: _imageFile!.path);

    setState(() {
      _imageFile = File(cropped!.path);
    });
  }

  void clear() {
    setState(() {
      _imageFile = null;
    });
  }

  void _uploadFile(File f, String title, String amount, String description,
      String nhours) async {
    final bucket = FirebaseStorage.instanceFor(
        bucket: "gs://tnstartup-blue-collar.appspot.com/");
    final storageRef = FirebaseStorage.instance.ref();

    final taskRef = storageRef.child("employees/${DateTime.now()}.jpg");

    try {
      await taskRef.putFile(f);
      print("Uploaded Successfully");
    } on FirebaseException catch (e) {
      print(e);
    }

    var document = await FirebaseFirestore.instance.collection("tasks");
    var taskid = document.add({
      "title": title,
      "description": description,
      "amount": amount,
      "nhours": nhours
    }).then((value) => value.id);
    print(taskid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: _pickImage, child: Text("Capture Image")),
            ElevatedButton(onPressed: clear, child: Text("Clear Image")),
            ElevatedButton(onPressed: _cropImage, child: Text("Crop Image")),
          ],
        ),
        if (_imageFile != null) ...[Image.file(_imageFile!)],
        ElevatedButton(
            onPressed: () async {
              if (_imageFile != null) {
                print("Uploading");
                _uploadFile(_imageFile!, widget.title, widget.amount,
                    widget.description, widget.nhours);
              }
            },
            child: Text("Submit"))
      ],
    );
  }
}
