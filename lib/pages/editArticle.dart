import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// TODO: Pembagian Branch - Fitur Edit Page
class EditArticle extends StatefulWidget {
  final Map item;
  const EditArticle({super.key, required this.item});

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  late final titleController = TextEditingController(
    text: widget.item['title'],
  );
  late final contentController = TextEditingController(
    text: widget.item['content'],
  );

  // Simpan category_id yang terpilih
  int? selectedCategoryId;

  // Status loading simpan dan loading kategori
  bool isSaving = false;
  bool isLoadingCategories = true;

  // List untuk menampung data kategori dari API
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi value awal dari item
    selectedCategoryId = int.tryParse(widget.item['category_id'].toString());
    fetchCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // Mengambil daftar kategori dari API
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:6767/api/category'),
      ); // Sesuaikan URL endpoint kategori Anda
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['data']);
          isLoadingCategories = false;
        });
      } else {
        setState(() => isLoadingCategories = false);
      }
    } catch (e) {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> updateProduct() async {
    setState(() => isSaving = true);

    final response = await http.put(
      Uri.parse('http://10.0.2.2:6767/api/posts/${widget.item['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': titleController.text,
        'content': contentController.text,
        'category_id': selectedCategoryId,
      }),
    );

    setState(() => isSaving = false);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil memperbarui artikel')),
      );
      // PERBAIKAN: Kembalikan nilai true ke halaman sebelumnya
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui artikel: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Artikel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Artikel'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Isi Artikel'),
            ),
            const SizedBox(height: 12),

            // Komponen Dropdown Kategori
            isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    value:
                        categories.any((cat) => cat['id'] == selectedCategoryId)
                        ? selectedCategoryId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['category_title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : updateProduct,
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }
}
