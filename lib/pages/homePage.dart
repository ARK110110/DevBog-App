import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_blog_app/pages/managementPage.dart';
import 'package:project_blog_app/pages/detailedArticle.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, this.username = 'Guest'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List articles = [];
  List categories = [
    {"id": 0, "category_title": "All"},
  ];
  bool isLoading = true;

  int selectedCategoryId = 0;
  int currentPage = 0;
  final int itemsPerPage = 3;

  TabController? _tabController;

  Future<void> getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:6767/api/posts'),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['data'] ?? [];
        data.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

        setState(() {
          articles = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> getCategory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:6767/api/category'),
      );

      if (response.statusCode == 200) {
        List fetchedCategories = jsonDecode(response.body)['data'] ?? [];

        fetchedCategories.sort(
          (a, b) => (a['id'] as int).compareTo(b['id'] as int),
        );

        setState(() {
          categories = [
            {"id": 0, "category_title": "All"},
            ...fetchedCategories,
          ];

          _tabController?.dispose();
          _tabController = TabController(
            length: categories.length,
            vsync: this,
          );
          _tabController!.addListener(() {
            if (_tabController!.indexIsChanging) return;
            setState(() {
              selectedCategoryId = categories[_tabController!.index]['id'];
              currentPage = 0;
            });
          });
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Fungsi untuk refresh manual (Pull-to-Refresh)
  Future<void> _refreshData() async {
    await getArticles();
    await getCategory();
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:6767/api/posts/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Artikel Berhasil Dihapus')));
      getArticles();
    } else {
      print('Gagal menghapus artikel: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    getArticles();
    getCategory();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List get filteredArticles {
    if (selectedCategoryId == 0) {
      return articles;
    }
    return articles
        .where((item) => item['category_id'] == selectedCategoryId)
        .toList();
  }

  List get paginatedArticles {
    final list = filteredArticles;
    int startIndex = currentPage * itemsPerPage;
    if (startIndex >= list.length) return [];
    int endIndex = startIndex + itemsPerPage;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '-';
    return dateStr.substring(0, 10);
  }

  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.length < 19) return '-';
    return dateStr.substring(11, 19);
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredArticles.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text("DevBlog"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: categories
              .map((cat) => Tab(text: cat['category_title'] ?? ''))
              .toList(),
        ),
        actions: [
          Text(
            widget.username,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () {
              // Action saat profil diklik
            },
            icon: const Icon(
              Icons.account_circle,
              color: Colors.black87,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Menunggu halaman ArticleManagement ditutup
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ArticleManagement(),
            ),
          );
          // Refresh artikel setelah kembali
          getArticles();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Mengaktifkan fitur narik layar ke bawah
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : paginatedArticles.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          "Tidak ada artikel pada kategori ini.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: paginatedArticles.length,
                          itemBuilder: (context, index) {
                            final item = paginatedArticles[index];

                            final ctgry = categories.firstWhere(
                              (cat) => cat["id"] == item["category_id"],
                              orElse: () =>
                                  {"category_title": "Tanpa Kategori"},
                            );

                            return GestureDetector(
                              onTap: () async {
                                // Menunggu halaman DetailedArticle/Edit ditutup
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailedArticle(item: item),
                                  ),
                                );
                                // Refresh artikel jika ada perubahan dari detail/edit
                                getArticles();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ctgry['category_title'],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['content'] ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Created:\n${formatDate(item['created_at'])}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Updated:\n${formatDate(item['updated_at'])} ${formatTime(item['updated_at'])}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              deletePost(item['id']),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 18),
                                onPressed: currentPage > 0
                                    ? () => setState(() => currentPage--)
                                    : null,
                              ),
                              Text(
                                "Halaman ${currentPage + 1} dari $totalPages",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    size: 18),
                                onPressed: currentPage < totalPages - 1
                                    ? () => setState(() => currentPage++)
                                    : null,
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