import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_todo_firebase/Auth/login_screen.dart';
import 'package:flutter_todo_firebase/screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder(
        stream:  FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return HomeScreen();
          } else {
            return  LoginScreen();
          }
        }
      ),
    );
  }
}
