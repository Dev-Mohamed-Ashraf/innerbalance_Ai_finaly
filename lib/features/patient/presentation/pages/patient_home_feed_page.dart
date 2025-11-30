import 'package:flutter/material.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/features/doctor/data/models/article_model.dart';
import 'package:innerbalance/features/patient/data/repositories/patient_repository_impl.dart';

class PatientHomeFeedPage extends StatefulWidget {
  const PatientHomeFeedPage({super.key});

  @override
  State<PatientHomeFeedPage> createState() => _PatientHomeFeedPageState();
}

class _PatientHomeFeedPageState extends State<PatientHomeFeedPage> {
  List<ArticleModel> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final repository = sl<PatientRepository>();
    final result = await repository.getFeedArticles();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading feed: ${failure.message}')),
          );
        }
      },
      (articles) {
        if (mounted) {
          setState(() {
            _articles = articles;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? const Center(child: Text('No articles found.'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.content,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Posted on: ${article.createdAt.day}/${article.createdAt.month}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
