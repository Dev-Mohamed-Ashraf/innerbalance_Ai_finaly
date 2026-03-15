import 'package:flutter/material.dart';
import 'package:innerbalancee/features/auth/presentation/pages/login_screen.dart';
import 'package:innerbalancee/features/ai/presentation/pages/ai_health_assessment_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  String _userName = 'User';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
        _userName = user.userMetadata?['name'] ?? 'Guest User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Colorful Header
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue[50],
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Stats Row (Optional placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Appointments', '0'),
                  _buildStatItem('Consultations', '0'),
                  _buildStatItem('Reports', '0'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Settings/Actions Group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SERVICES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.psychology_outlined,
                      color: Colors.purple,
                      title: 'AI Addiction Analysis',
                      subtitle: 'Smart health assessment',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AIHealthAssessmentPage()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text(
                    'ACCOUNT SETTINGS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      color: Colors.blue,
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_none,
                      color: Colors.orange,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.security,
                      color: Colors.green,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.logout,
                      color: Colors.red,
                      title: 'Logout',
                      textColor: Colors.red,
                      showChevron: false,
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor ?? Colors.black87),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: showChevron ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
