import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pj/FilterPage_restapi.dart';
import 'RegisterPage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

/* [ 로그인 성공 페이지 ]---------------------------------------
  로그인 성공 시 해당 사용자의 닉네임을 받아와서 보여주는 페이지
------------------------------------------------------------*/

class SuccessLoginPage extends StatefulWidget {
  const SuccessLoginPage({Key? key}) : super(key: key);

  @override
  State<SuccessLoginPage> createState() => _SuccessLoginPage();
}

class _SuccessLoginPage extends State<SuccessLoginPage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('user')
            .where('email', isEqualTo: _authentication.currentUser!.email)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${docs[0]['userName']} 님',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  '어서오세요!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ElevatedButton(
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) => const FilterPage_rapi()),
                            (route) => false);
                  },
                  child: const Text('가게 추천받으러 가기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}