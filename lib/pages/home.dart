import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:movies/model.dart';
import 'package:movies/pages/add_movie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movies/signin_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  signinServices signin = signinServices();
  final _loginFormKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String _email ="none";
  late bool loggedIn;

  currentUser() {
    User? user = auth.currentUser;
    if (user == null) {
      setState(() {
        loggedIn = false;
      });
    } else {
      setState(() {
        _email = user.email!;
        loggedIn = true;
      });
    }
  }

  @override
  void initState() {
    currentUser();
    super.initState();
  }
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final _fire = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          loggedIn
              ? TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0)), //this right here
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                width: MediaQuery.of(context).size.width * 0.55,
                                height: 149,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  // color: Colors.grey
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Center(
                                        child: Text(
                                      "Do you really want to Logout?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          TextButton(
                                            child: Text(
                                              "Logout",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              signin.signOut();
                                              setState(() {
                                                loggedIn = false;
                                                _email = "none";
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ]),
                                  ],
                                ),
                              ));
                        });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      "LOGOUT",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ))
              : TextButton(
                  onPressed: () {
                    signin.googSignIn(context).then((value) {
                      if (value != null) {
                        print("Logged in successfully");

                        setState(() {
                          loggedIn = true;
                          _email = value.email!;
                        });
                      } else {
                        print("error");
                      }
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ))
        ],
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "Add Movie",
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
        elevation: 10,
        backgroundColor: Colors.grey,
        onPressed: () {
          loggedIn
              ? Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddMovie()))
              : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please Login to add movies"),
                  duration: Duration(seconds: 5),
                ));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
              stream: _fire.collection("movies").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs
                      .where((element) => element["user"] == _email)
                      .toList();
                  print("Email:" + _email);
                  return documents.isNotEmpty
                      ? Stack(
                          children: [
                            Container(
                              color: Colors.black,
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: ExactAssetImage(
                                        'assets/images/login_background.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 2.0, sigmaY: 2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.0)),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  color: Colors.black,
                                  child: const Center(
                                      child: Text(
                                        "Movies Watched!!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            // backgroundColor: Colors.black,
                                            fontSize: 20),
                                      )),
                                ),

                                SingleChildScrollView(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.8,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: documents.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot data = documents[index];

                                          return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 15),
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular((20)),
                                                color:
                                                    Colors.white.withOpacity(0.7),
                                              ),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              width:
                                                  MediaQuery.of(context).size.width,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.2,
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    child: Image.network(
                                                        data['moviePoster']),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width:MediaQuery.of(context).size.width* 0.7,
                                                            child: Text(
                                                              "Title : " +
                                                                  data["movieName"],
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle.italic,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "Director: " +
                                                                data[
                                                                    "movieDirector"],
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors.black,
                                                                fontStyle: FontStyle
                                                                    .italic),
                                                          )
                                                        ],
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: const Color(
                                                              0x9A9E1616),
                                                        ),
                                                        onPressed: () {
                                                          _fire
                                                              .collection('movies')
                                                              .doc(
                                                                  data["movieName"])
                                                              .delete();
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ));
                                        }),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Stack(
                          children: [
                            Container(
                              color: Colors.black,
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: ExactAssetImage(
                                        'assets/images/login_background.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.0)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              // padding: EdgeInsets.only(top: 20),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(top: 20, bottom: 10),
                                    color: Colors.black,
                                    child: const Center(
                                        child: Text(
                                      "Movies Watched!!",
                                      style: TextStyle(
                                          color: Colors.white,
                                          // backgroundColor: Colors.black,
                                          fontSize: 20),
                                    )),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.25,
                                  ),
                                  _email!="none"
                                      ? Text(
                                    "Add movies to display them in list",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.italic),
                                  )
                                  : Text(
                                    "Login to add/display moview",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                } else {
                  return Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/login_background.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.0)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular((20)),
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width,
                        child: Text("Welcome to the Movies List"),
                      )
                    ],
                  );
                }
              },
            ),
    );
  }
}
