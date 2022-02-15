// import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movies/pages/home.dart';

class AddMovie extends StatefulWidget {
  const AddMovie({Key? key}) : super(key: key);

  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  final _fire = FirebaseFirestore.instance;
  TextEditingController movieName = TextEditingController();
  TextEditingController movieDirector = TextEditingController();
  TextEditingController moviePoster = TextEditingController();

  late File _image;

  late String email;

  currentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    setState(() {
      email = user.email!;
    });
  }

  _cropImage(filePath) async {
    final croppedImage = await ImageCropper.cropImage(
      cropStyle: CropStyle.rectangle,
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 360,
      aspectRatio: const CropAspectRatio(ratioX: 4.0, ratioY: 2.0)
    );

    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
        moviePoster.text = movieName.text + ".jpg";
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  Future getImageFromGallery() async {
    ImagePicker imagePicker = new ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    await _cropImage(image?.path);
  }

  late String imageUrl;
  Future uploadPic(BuildContext context) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(moviePoster.text);
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    await uploadTask
        .whenComplete(() => firebaseStorageRef.getDownloadURL().then((value) {
              print("imageUrl:" + value);
              _fire.collection("movies").doc(movieName.text).set({
                'movieName': movieName.text,
                'movieDirector': movieDirector.text,
                'moviePoster': value,
                'user': email
              }).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Movie added successfully"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ))).whenComplete(() => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())));
            }));
  }

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Add Movies",
            style: TextStyle(color: Colors.grey),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      uploadPic(context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0x9A9E1616)),
                    child: const Center(
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  )),
              SizedBox(
                width: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0x9A9E1616)),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      )))
            ],
          )),
      backgroundColor: Colors.black45,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: movieName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  return value == null ? "Please enter movie name" : null;
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.only(top: 0),
                  label: Text(
                    "Movie Name",
                    style: TextStyle(color: Colors.grey),
                  ),
                  // hintText: "Enter the movie name",
                  // hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: movieDirector,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  return value == null ? "Please enter movie name" : null;
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.only(top: 0),
                  label: Text(
                    "Movie Director",
                    style: TextStyle(color: Colors.grey),
                  ),
                  // hintText: "Enter the name of the director",
                  // hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () => movieName.text == ""
                    ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please enter the movie name"),
                        duration: Duration(seconds: 5),
                      ))
                    : getImageFromGallery(),
                child: TextFormField(
                  enabled: false,
                  style: TextStyle(color: Colors.white),
                  controller: moviePoster,
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    return value == null ? "Please select poster" : null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.only(top: 0),
                    label: Text(
                      "Movie Poster",
                      style: TextStyle(color: Colors.grey),
                    ),
                    // hintText: "Enter the name of the director",
                    // hintStyle: TextStyle(color: Colors.grey),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
