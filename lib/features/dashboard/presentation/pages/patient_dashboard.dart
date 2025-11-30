import 'package:flutter/material.dart';
import 'package:innerbalance/features/patient/presentation/pages/find_doctors_page.dart';
import 'package:innerbalance/features/patient/presentation/pages/my_doctors_page.dart';
import 'package:innerbalance/features/patient/presentation/pages/patient_home_feed_page.dart';
import 'package:innerbalance/features/patient/presentation/pages/patient_profile_page.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PatientHomeFeedPage(),
    FindDoctorsPage(),
    MyDoctorsPage(),
    PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InnerBalance'),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Find Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'My Doctors',
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
