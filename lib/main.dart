import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'FilterPage_restapi.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'SuccessRegister.dart';
import 'MapPage.dart';
import 'OneRestaurantPage.dart';
import 'RestaurantListPage.dart';
import 'RestaurantInfoPage.dart';
import 'SelectResultViewTypePage.dart';

import 'package:flutter_provider/flutter_provider.dart';
import 'package:provider/provider.dart';
import 'Algorithm/ShoplistProvider.dart';
import 'map/LocationProvider.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>SelectedShops()),
      ChangeNotifierProvider(create: (_)=>CurrLocation())
    ],
    child: MyApp(),
  ),);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      //StreamBuilder > steam을 계속 보고 변화를 감지
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // return LoginPage();
          if (snapshot.hasData){
            return const FilterPage_rapi();
          }
          else {
            return const LoginPage();
          }
        }
      ),

    );
  }
}

