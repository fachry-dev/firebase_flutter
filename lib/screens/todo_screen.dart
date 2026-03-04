import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Asumsi: Anda akan meneruskan nama kategori (misalnya 'target SKL')
class TodoScreen extends StatefulWidget {
  final String categoryName;

  // Anda bisa menambahkan categoryId jika data todo difilter berdasarkan ID kategori
  const TodoScreen({super.key, required this.categoryName});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Data dummy yang meniru tampilan di gambar
  // Dalam aplikasi nyata, data ini akan diambil dari Firebase, difilter berdasarkan categoryName
  final List<Map<String, dynamic>> dummyTasks = [
    {'id': '1', 'title': 'MindMapping | Diniyah', 'check': false},
    {'id': '2', 'title': 'Todo Application | Flutter', 'check': true},
    {'id': '3', 'title': 'TalkShow | English', 'check': false},
    {'id': '4', 'title': 'Sirah Video | Diniyah', 'check': false},
    {'id': '5', 'title': 'MindMapping | Diniyah', 'check': false},
    {'id': '6', 'title': 'Todo Application | Flutter', 'check': false},
    {'id': '7', 'title': 'TalkShow | English', 'check': false},
    {'id': '8', 'title': 'Poster Diniyah', 'check': false},
    {'id': '9', 'title': 'News Application | Flutter', 'check': false},
  ];

  // --- Fungsi (Contoh bagaimana Anda akan mengintegrasikan Firebase) ---

  // Fungsi Toggle (Contoh, karena kita menggunakan dummy data)
  void toggleTaskCheck(String id, bool currentValue) {
    setState(() {
      final task = dummyTasks.firstWhere((task) => task['id'] == id);
      task['check'] = !currentValue;
    });
    
    // Di aplikasi nyata, Anda akan menjalankan update Firebase di sini:
    /*
    FirebaseFirestore.instance.collection('todo').doc(id).update({
      "check": !currentValue
    });
    */
  }

  // Widget kustom untuk item todo
  Widget _buildTodoItem(Map<String, dynamic> task) {
    bool isChecked = task['check'];
    String title = task['title'];
    
    // Asumsi format title adalah "Task | Subkategori"
    List<String> parts = title.split('|');
    String mainTitle = parts[0].trim();
    String subTitle = parts.length > 1 ? parts[1].trim() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox Kustom seperti di gambar
          GestureDetector(
            onTap: () => toggleTaskCheck(task['id'] as String, isChecked),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isChecked ? Colors.green : Colors.grey.shade400, 
                  width: 2
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
          // Judul Todo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: isChecked ? Colors.black38 : Colors.black87,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subTitle.isNotEmpty)
                  Text(
                    '| $subTitle',
                    style: TextStyle(
                      fontSize: 14,
                      color: isChecked ? Colors.black38 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung progress dari dummy data
    int totalTasks = dummyTasks.length;
    int completedTasks = dummyTasks.where((task) => task['check'] == true).length;
    String progressText = '$completedTasks of $totalTasks Task';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Kita buat tombol back kustom
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            // Ikon Save/Archive di kanan atas
            const Icon(Icons.save_alt, color: Colors.green, size: 28), 
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Kategori ---
            Text(
              widget.categoryName, // Gunakan nama kategori yang diteruskan
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              progressText,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const Divider(color: Colors.grey, height: 25),

            // --- Daftar Todo ---
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: dummyTasks.length,
              itemBuilder: (context, index) {
                return _buildTodoItem(dummyTasks[index]);
              },
            ),
            const SizedBox(height: 100), // Ruang di bagian bawah
          ],
        ),
      ),
      
      // --- BOTTOM NAVIGATION BAR KUSTOM ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon Daftar/List
            IconButton(
              icon: const Icon(Icons.format_list_bulleted, color: Colors.black, size: 28),
              onPressed: () { /* Aksi List */ },
            ),
            // Ikon Edit/Pena
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 28),
              onPressed: () { /* Aksi Edit */ },
            ),
            // Ikon Tambah (+) - Tengah
            FloatingActionButton(
              onPressed: () {
                // Aksi Tambah Todo (Anda bisa memanggil showDialog di sini)
              },
              mini: true,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            // Ikon Tiga Titik/More
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
              onPressed: () { /* Aksi More/Options */ },
            ),
          ],
        ),
      ),
    );
  }
}
