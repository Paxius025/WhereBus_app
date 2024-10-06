import 'package:flutter/material.dart';
import 'package:wherebus_app/screens/edit_profile_screen.dart';  // Import EditProfileScreen

class NavigationBarWidget extends StatefulWidget {
  final String username;
  final String email;
  final int userId;

  const NavigationBarWidget({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
  });

  @override
  _NavigationBarWidgetState createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int _selectedIndex = 0;

  // ฟังก์ชันสำหรับการเปลี่ยนหน้าเมื่อเลือกใน BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // เมื่อกดปุ่ม Profile จะไปที่ EditProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(
            username: widget.username,
            email: widget.email,
            userId: widget.userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
