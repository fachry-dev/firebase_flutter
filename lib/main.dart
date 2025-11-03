import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_todo_firebase/Auth/login_screen.dart';
import 'package:flutter_todo_firebase/screens/camera_screen.dart';
import 'package:flutter_todo_firebase/screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  await Permission.camera.request();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera,));
}

class MyApp extends StatelessWidget {

  final CameraDescription camera;
  MyApp({super.key, required this.camera});

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
            return  CameraScreen(camera: camera);
          }
        }
      ),
    );
  }
}
