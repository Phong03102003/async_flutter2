import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:async_flutter2/article_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEE, dd\'th\' MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Explore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search for article',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: CategoriesBar(
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ArticleList(
                    category: _selectedCategory, searchQuery: _searchQuery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesBar extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoriesBar({Key? key, required this.onCategorySelected})
      : super(key: key);

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  List<String> categories = const [
    'All',
    'Politics',
    'Sports',
    'Health',
    'Music',
    'Tech'
  ];

  int currentCategory = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              currentCategory = index; // Cập nhật chỉ số của danh mục hiện tại
            });
            widget.onCategorySelected(categories[
                index]); // Gọi hàm callback để thông báo danh mục được chọn
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: currentCategory == index ? Colors.black : Colors.white,
              border: Border.all(),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  color: currentCategory == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ArticleList extends StatelessWidget {
  final String category;
  final String searchQuery;

  const ArticleList(
      {Key? key, required this.category, required this.searchQuery})
      : super(key: key);

  List<Article> _filterArticlesByQuery(List<Article> articles, String query) {
    if (query.isEmpty) {
      return articles;
    }

    final lowercaseQuery = query.toLowerCase();
    return articles.where((article) {
      final titleMatch = article.title.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch =
          article.description.toLowerCase().contains(lowercaseQuery);
      final categoryMatch = article.category
          .toLowerCase()
          .contains(lowercaseQuery); // Thêm điều kiện tìm kiếm trong category
      return titleMatch || descriptionMatch || categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _loadArticlesByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          final filteredArticles =
              _filterArticlesByQuery(snapshot.data!, searchQuery);
          return ListView.builder(
            itemCount: filteredArticles.length,
            itemBuilder: (context, index) {
              final article = filteredArticles[index];
              return ArticleTile(article: article);
            },
          );
        } else {
          return const Center(
            child: Text('No articles available'),
          );
        }
      },
    );
  }

  Future<List<Article>> _loadArticlesByCategory(String category) async {
    String url =
        'https://newsapi.org/v2/everything?q=tesla&from=2024-02-21&sortBy=publishedAt&apiKey=65247db2e60541e0887a3251b6cf13c8';

    // Thêm danh mục vào URL nếu danh mục không phải là "All"
    if (category != 'All') {
      url += '&category=$category';
    }

    // Thêm từ khóa tìm kiếm vào URL nếu có
    if (searchQuery.isNotEmpty) {
      url += '&q=${Uri.encodeComponent(searchQuery.trim())}';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'];
        final List<Article> filteredArticles = articles
            .map((articleJson) => Article.fromJson(articleJson))
            .toList();
        return filteredArticles;
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      // ignore: avoid_print
      print('An error occurred: $e');
      return [];
    }
  }
}

class ArticleTile extends StatelessWidget {
  final Article article;

  const ArticleTile({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailsScreen(article: article),
          ),
        );
      },
      child: Container(
        height: 128,
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                article.urlToImage ?? '',
                fit: BoxFit.cover,
                height: 128,
                width: 128,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 128,
                    width: 128,
                    color: Colors.lightBlue,
                  );
                },
              ),
            ),
            const SizedBox(
                width:
                    8), // Thêm khoảng cách giữa hình ảnh và thông tin bài báo
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Source: ${article.source}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'By: ${article.author}',
                      maxLines: 1, // Giới hạn văn bản này trong một dòng
                      overflow: TextOverflow
                          .ellipsis, // Hiển thị dấu "..." nếu văn bản vượt quá kích thước
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          // ignore: unnecessary_string_interpolations
                          '${article.category}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        // ignore: prefer_const_constructors
                        Spacer(), // Sử dụng Spacer để tạo khoảng trống giữa các widget
                        Text(
                          // ignore: unnecessary_string_interpolations
                          '${article.publishedAt.substring(0, 10)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({Key? key, required this.article})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.urlToImage ?? '',
              fit: BoxFit.cover,
              height: 400,
              width: 1800,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 128,
                  width: 128,
                  color: Colors.lightBlue,
                );
              },
            ),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Published At: ${article.publishedAt.substring(0, 10)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'By ${article.source}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              article.content ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
