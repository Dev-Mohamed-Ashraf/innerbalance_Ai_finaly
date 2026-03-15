import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/features/doctor/data/models/article_model.dart';
import 'package:innerbalancee/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/create_article_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List<ArticleModel> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repository = sl<DoctorRepository>();
    final result = await repository.getDoctorArticles(userId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading articles: ${failure.message}')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticlePage()),
          );
          if (result == true) {
            _loadArticles();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? const Center(child: Text('No articles published yet.'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          article.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${article.createdAt.day}/${article.createdAt.month}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
