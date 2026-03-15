import 'package:flutter/material.dart';
import 'package:innerbalancee/core/theme/app_palette.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/articles_page.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/doctor_profile_page.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/my_patients_page.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/requests_page.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MyPatientsPage(),
    RequestsPage(),
    ArticlesPage(),
    DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InnerBalance Doctor'),
        centerTitle: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Articles',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
