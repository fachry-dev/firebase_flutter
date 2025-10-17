import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController todoController = TextEditingController();
  String message = '';

  Future <void> addTodo() async{
    try{
      await FirebaseFirestore.instance.collection("todo").add({
        "title" : todoController.text,
        "time" : FieldValue.serverTimestamp(),
        "chek" :false
      });
      setState(() {
        message = "Berhasil menambahkan data ${todoController.text}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar (content: Text(message))
        );
      todoController.clear();
    } catch (e) {
      setState(() {
        message = "eror $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar (content: Text(message))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO APP"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            }, 
            icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text("Selamat Datang ${user!.displayName}", style: TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold
            ),),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child :TextField(
          controller: todoController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                addTodo();
              }, icon: Icon(Icons.send)),
            border: OutlineInputBorder()
          ),
        ),
        ),
    );
  }
}