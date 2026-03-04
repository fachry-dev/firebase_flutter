import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_todo_firebase/Auth/login_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeCamera;
  XFile? imageFile;
  int faceCount = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.high);
    initializeCamera = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    try {
      await initializeCamera;
      final image = await controller.takePicture();
      final faces = await detectFace(File(image.path));

      setState(() {
        imageFile = image;
        faceCount = faces.length;
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<List<Face>> detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    );
    final faceDetector = FaceDetector(options: options);
    final faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();
    return faces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                  const Text(
                    "Face Detection",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "lanjutkan",
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FutureBuilder(
                          future: initializeCamera,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return imageFile != null
                                  ? Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : CameraPreview(controller);
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        // Frame Corners (L-Shapes)
                        const Positioned.fill(child: CameraOverlayPainter()),

                        if (imageFile == null)
                          Positioned(
                            bottom: 20,
                            child: GestureDetector(
                              onTap: takePicture,
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  const Text(
                    "Wajah Terdeteksi",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    "$faceCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => setState(() => imageFile = null),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Foto Ulang"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: faceCount > 0
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            )
                          : null,
                      child: const Text(
                        "Absen",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraOverlayPainter extends StatelessWidget {
  const CameraOverlayPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 20, left: 20, child: _corner(top: 2, left: 2)),
        Positioned(top: 20, right: 20, child: _corner(top: 2, right: 2)),
        Positioned(bottom: 20, left: 20, child: _corner(bottom: 2, left: 2)),
        Positioned(bottom: 20, right: 20, child: _corner(bottom: 2, right: 2)),
      ],
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top != null
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: bottom != null
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: left != null
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: right != null
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
