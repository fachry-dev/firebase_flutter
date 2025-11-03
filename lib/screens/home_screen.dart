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
  TextEditingController editController = TextEditingController();
  String message = '';
  String search = '';

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
 

 Future<void> editTodo(id) async{
  try {
     await FirebaseFirestore.instance.collection('todo').doc(id).update({
      "title": editController.text
     });
     setState(() {
      message = "Berhasil edit data ${editController.text}";
     });
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
     );
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
              title: Text("Logout"),
              content: Text("Are you sure?"),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("No")),
                TextButton(onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                }, child: Text("Yess")),
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
            TextField(
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search todo",
                border: OutlineInputBorder()
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 20,),
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
                  final searchhData = data.where((element) {
                    final keyword = element['title'].toString().toLowerCase();
                    return keyword.contains(search);
                  },).toList();

                  if(searchhData.isEmpty){
                    return Center(child: Text("Data tidak ditemukan"),);
                  }
                  
                  return ListView.builder(
                    itemCount: searchhData.length,
                    itemBuilder: (context, index) {
                      final todo = searchhData[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo['check'], 
                            onChanged: (value) async {
        
                              await FirebaseFirestore.instance.collection('todo').doc(todo.id).update({
                                "check":value
                              });
                            },
                            ),
                          title: Text(todo['title'],style: TextStyle(
                            decoration: todo['check'] ? TextDecoration.lineThrough : null
                          ),),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () {
                                editController.text = todo['title'];
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    title: Text("Edit"),
                                    content: Text("Input your new title"),
                                    
                                    actions: [
                                      TextField(
                                        controller: editController,
                                        decoration: InputDecoration(
                                          labelText: 'Edit',
                                          hintText: "Input your edit",
                                          border: OutlineInputBorder()
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            editTodo(todo.id);
                                            Navigator.pop(context);
                                           
                                          },
                                           child: Text("Submit")),
                                      )
                                    ], 
                                  );
                                },);
                              }, icon: Icon(Icons.edit,color: Colors.blue,)),
                              IconButton(onPressed: () {
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                      title: Text("delete"),
                                      content: Text("Are you sure?"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          Navigator.pop(context);
                                        }, child: Text("Noo")),
                                        TextButton(onPressed: () async {
                                          await FirebaseFirestore.instance.collection('todo').doc(todo.id).delete();
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Berhasil hapus data"))
                                          );
                                        }, child: Text("Yess"))
                                      ],
                                  );
                                },);
                              }, icon: Icon(Icons.delete,color: Colors.red,)),
                            ],
                          ),
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