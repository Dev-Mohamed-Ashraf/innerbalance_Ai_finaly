import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/features/doctor/data/models/article_model.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/doctor_profile_page.dart';
import 'package:innerbalancee/features/patient/data/repositories/patient_repository_impl.dart';

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
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
                      elevation: 0.5,
                      shape: const RoundedRectangleBorder(), // Flat look like mobile FB
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header (Doctor Info)
                          InkWell(
                            onTap: () {
                              final doctor = DoctorProfileModel(
                                id: article.doctorId,
                                name: article.doctorName ?? 'Unknown Doctor',
                                specialization: 'Specialist',
                                price: 0,
                                bio: '',
                                avatarUrl: article.doctorAvatarUrl ?? '',
                                availableHours: {},
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorProfilePage(doctor: doctor),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    backgroundImage: article.doctorAvatarUrl != null &&
                                            article.doctorAvatarUrl!.isNotEmpty
                                        ? NetworkImage(article.doctorAvatarUrl!)
                                        : null,
                                    child: article.doctorAvatarUrl == null ||
                                            article.doctorAvatarUrl!.isEmpty
                                        ? const Icon(Icons.person, color: Colors.blue)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.doctorName ?? 'Doctor',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          '${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                                ],
                              ),
                            ),
                          ),
                          // Article Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                                const SizedBox(height: 4),
                                Text(
                                  article.content,
                                  style: const TextStyle(fontSize: 15, height: 1.4),
                                  textDirection: TextDirection.rtl, // Supporting Arabic text
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Large Interactive Image
                          if (article.imageUrl != null)
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, article.imageUrl!),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 400),
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                child: Image.network(
                                  article.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          // Interaction Bar (Like FB)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                                  label: const Text('Like'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.comment_outlined, size: 20),
                                  label: const Text('Comment'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.share_outlined, size: 20),
                                  label: const Text('Share'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const CloseButton(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
