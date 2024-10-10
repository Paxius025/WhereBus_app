//navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:wherebus_app/screens/edit_profile_screen.dart';
import 'package:wherebus_app/screens/admin/admin_dashboard.dart'; // Import Admin Dashboard

class NavigationBarWidget extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String role; // รับ role ของผู้ใช้ (user, driver, admin)

  const NavigationBarWidget({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
    required this.role,
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

    if (index == 1 && widget.role == 'admin') {
      // ถ้าผู้ใช้เป็น Admin จะไปที่ Admin Dashboard พร้อม Fade Animation ที่เร็วขึ้น
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AdminDashboardScreen(
            username: widget.username,
            userId: widget.userId,
            email: widget.email,
            role: widget.role,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(
              milliseconds: 100), // กำหนดความเร็วให้จางหายเร็วขึ้น
        ),
      );
    } else if (index == (widget.role == 'admin' ? 2 : 1)) {
      // ไปที่ EditProfileScreen สำหรับทุก role พร้อม Fade Animation ที่เร็วขึ้น
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              EditProfileScreen(
            username: widget.username,
            email: widget.email,
            userId: widget.userId,
            role: widget.role,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(
              milliseconds: 100), // กำหนดความเร็วให้จางหายเร็วขึ้น
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.pin_drop),
          label: 'Map',
        ),
        if (widget.role == 'admin') // แสดงไอคอน Dashboard เฉพาะ Admin
          const BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Admin',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF40534C), // สีเมื่อถูกเลือก
      unselectedItemColor: const Color(0xFF40534C), // สีเมื่อไม่ถูกเลือก
      onTap: _onItemTapped,
    );
  }
}
