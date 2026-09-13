import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final categoryTitleController = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    categoryTitleController.dispose();
    super.dispose();
  }

  Future<void> addCategory() async {
    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://10.0.2.2:6767/api/categories',
        ), // Sesuaikan endpoint API kamu
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'category_title': categoryTitleController.text}),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menyimpan kategori: ${response.body}'),
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya jika berhasil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kategori: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: categoryTitleController,
              decoration: const InputDecoration(labelText: 'Category Title'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : addCategory,
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
