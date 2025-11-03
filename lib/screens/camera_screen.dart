import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeCamera;
  XFile? imageFile;
  String message = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    initializeCamera = controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> takepicture() async{
    try {
      await initializeCamera;
      final image = await controller.takePicture();

      setState((){
        imageFile = image;
      });
     } catch(e){
       setState((){
        message = "gagal mengambil gambar karena :$e";
       });
    }
    
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera Screen"),
        ),
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: initializeCamera,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  return imageFile != null ? Image.file(File(imageFile!.path)) : CameraPreview(controller);
                } else {
                  return Center(child: CircularProgressIndicator(),);
                }
              },
            )
        ],
        ),
       ),
        );
  }
}