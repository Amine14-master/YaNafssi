import 'package:flutter/material.dart';
import '../../services/localization_service.dart';
import 'helper_rooms_screen.dart';
import 'gifts_screen.dart';
import 'helper_profile_screen.dart';

class HelperMainScreen extends StatefulWidget {
  const HelperMainScreen({super.key});

  @override
  State<HelperMainScreen> createState() => _HelperMainScreenState();
}

class _HelperMainScreenState extends State<HelperMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HelperRoomsScreen(),
    const GiftsScreen(),
    const HelperProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF059669).withOpacity(0.1),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.meeting_room_outlined),
              selectedIcon: const Icon(
                Icons.meeting_room_rounded,
                color: Color(0xFF059669),
              ),
              label: LocalizationService().translate('rooms'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.card_giftcard_outlined),
              selectedIcon: const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFF059669),
              ),
              label: LocalizationService().translate('gifts'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(
                Icons.person_rounded,
                color: Color(0xFF059669),
              ),
              label: LocalizationService().translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
