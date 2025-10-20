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

  Future<void> addTodo() async{
    try {
      await FirebaseFirestore.instance.collection("todo").add({
       'title': todoController.text,
       'time': FieldValue.serverTimestamp(),
       'check': false
      });
      setState(() {
        message = "Berhasil menambahkan data ${todoController.text}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
      todoController.clear();
    } catch (e) {
      setState(() {
        message = "error $e";
         });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
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
            onPressed: () {
             showDialog(context: context, builder: (context) {
               return AlertDialog(
                title:Text("Logout"),
                content: Text("Are you sure to logout?"),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  },child: Text("No"),),
                   TextButton(onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                   },child: Text("Yes"),),
                ],
               );
             },);
            }, 
            icon: Icon(Icons.exit_to_app))
        ],
      ), 
      body: Center(
        child: Column(
          children: [
            
            Text("Selamat datang ${user!.displayName}",style: TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold
            ),),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('todo').snapshots(), 
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }else if(snapshot.hasError){
                    return Center(child: Text(snapshot.error.toString()),);
                  }

                  final data = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final todo = data[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo['check'], 
                            onChanged: (value) async{
                              await FirebaseFirestore.instance.collection('todo').doc(todo.id).update({
                                'check': value
                              });
                            },
                            ),
                          title: Text(todo['title']), 
                        ),
                      );
                    },
                    );
                },)
              )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: todoController,
          decoration:InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                addTodo();
              },
               icon: Icon(Icons.send)),
            border: OutlineInputBorder()
          ),
        ),
        ),
    );
  }
}