import 'package:flutter/material.dart';
import 'package:project_blog_app/pages/editArticle.dart';

class DetailedArticle extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailedArticle({super.key, required this.item});

  @override
  State<DetailedArticle> createState() => _DetailedArticleState();
}

class _DetailedArticleState extends State<DetailedArticle> {
  // Format Tanggal (YYYY-MM-DD)
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '-';
    return dateStr.substring(0, 10);
  }

  // Format Waktu (HH:mm:ss)
  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.length < 19) return '-';
    return dateStr.substring(11, 19);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Artikel"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol EDIT di bagian atas Judul
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Direct ke layar edit artikel jika nanti dibutuhkan
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditArticle(item: article),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mengarahkan ke halaman Edit Artikel..."),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Judul Artikel
            Text(
              article['title'] ?? 'Tanpa Judul',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Meta Info: Tanggal & Waktu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dibuat:",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatDate(article['created_at']),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Diperbarui:",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${formatDate(article['updated_at'])} ${formatTime(article['updated_at'])}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),

            // Isi Konten Artikel Full (Tanpa Limit / Truncate)
            Text(
              article['content'] ?? 'Tidak ada konten artikel.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}