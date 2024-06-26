import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedInUser;
  String userData = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUserData();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getUserData() async {
    if (loggedInUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(loggedInUser!.uid).get();
      setState(() {
        userData = userDoc['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: TextEditingController(text: userData),
              onChanged: (value) {
                userData = value;
              },
              decoration: InputDecoration(
                labelText: 'Your data',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _firestore.collection('users').doc(loggedInUser!.uid).set({
                  'data': userData,
                });
              },
              child: Text('Update Data'),
            ),
          ],
        ),
      ),
    );
  }
}