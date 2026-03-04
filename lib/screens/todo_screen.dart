import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class TodoScreen extends StatefulWidget {
  final String categoryName;
  const TodoScreen({super.key, required this.categoryName});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> categories = [
    {
      'name': 'Target SKL',
      'tasks': [
        {'id': '1', 'title': 'MindMapping | Diniyah', 'check': false},
        {'id': '2', 'title': 'Todo Application | Flutter', 'check': true},
      ],
    },
    {
      'name': 'Project IT',
      'tasks': [
        {'id': '3', 'title': 'Firebase Auth Setup', 'check': false},
      ],
    },
    {'name': 'Diniyah', 'tasks': []},
    {'name': 'English', 'tasks': []},
  ];

  void _addNewCategory() {
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Bagian Baru"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: "Nama Bagian (Contoh: Tahfidz)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  categories.add({
                    'name': categoryController.text,
                    'tasks': [],
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _addNewTodo(int categoryIndex) {
    TextEditingController todoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Task di ${categories[categoryIndex]['name']}"),
        content: TextField(
          controller: todoController,
          decoration: const InputDecoration(hintText: "Nama Task | Subtitle"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (todoController.text.isNotEmpty) {
                setState(() {
                  categories[categoryIndex]['tasks'].add({
                    'id': DateTime.now().toString(),
                    'title': todoController.text,
                    'check': false,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  void _removeCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }

  void toggleTaskCheck(int catIndex, int taskIndex) {
    setState(() {
      categories[catIndex]['tasks'][taskIndex]['check'] =
          !categories[catIndex]['tasks'][taskIndex]['check'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.save_alt, color: Colors.green, size: 28),
          SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        itemCount: categories.length,
        itemBuilder: (context, catIndex) {
          final category = categories[catIndex];
          int completed = category['tasks']
              .where((t) => t['check'] == true)
              .length;
          int total = category['tasks'].length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "$completed of $total Task",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue,
                        ),
                        onPressed: () => _addNewTodo(catIndex),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeCategory(catIndex),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: category['tasks'].length,
                itemBuilder: (context, taskIndex) {
                  var task = category['tasks'][taskIndex];
                  return _buildTodoItem(task, catIndex, taskIndex);
                },
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),

      // BOTTOM NAVBAR
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTodoItem(
    Map<String, dynamic> task,
    int catIndex,
    int taskIndex,
  ) {
    bool isChecked = task['check'];
    List<String> parts = task['title'].split('|');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => toggleTaskCheck(catIndex, taskIndex),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isChecked ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isChecked ? Colors.green : Colors.transparent,
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts[0].trim(),
                  style: TextStyle(
                    fontSize: 16,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? Colors.grey : Colors.black,
                  ),
                ),
                if (parts.length > 1)
                  Text(
                    "| ${parts[1].trim()}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.format_list_bulleted, size: 28),
          const Icon(Icons.edit_outlined, size: 28),
          FloatingActionButton(
            onPressed: _addNewCategory,
            mini: true,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const Icon(Icons.more_horiz, size: 28),
        ],
      ),
    );
  }
}
