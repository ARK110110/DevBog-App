import 'package:flutter/material.dart';
import 'package:project_blog_app/pages/addCategory.dart';
import 'package:project_blog_app/pages/addPost.dart';

// Import file halaman tujuan Anda di sini
// import 'add_post_page.dart';
// import 'add_category_page.dart';
// TODO: Pembagian Branch - Fitur Management Page
class ArticleManagement extends StatefulWidget {
  const ArticleManagement({super.key});

  @override
  State<ArticleManagement> createState() => ArticleManagementState();
}

class ArticleManagementState extends State<ArticleManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article Managment Dashboard')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100], // Background lembut agar kontainer menonjol
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontainer 1: Post (Diubah menjadi Tombol Navigation)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Pindah ke halaman AddPostPage
                   
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPost()),
                  );
                  
                  
                  // Contoh SnackBar sementara sebelum file di-import
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka Halaman Post...')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kontainer 2: Kategori (Diubah menjadi Tombol Navigation)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Pindah ke halaman AddCategoryPage
                   
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddCategory()),
                  );
                  

                  // Contoh SnackBar sementara sebelum file di-import
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka Halaman Kategori...')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Kategori",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}