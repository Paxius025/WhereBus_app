// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_status_screen.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart'; // Import Navigation Bar

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  final int userId;
  final String email; // เพิ่ม email ที่รับจากหน้าอื่น
  final String role; // เพิ่ม role ที่รับจากหน้าอื่น

  const AdminDashboardScreen({
    super.key,
    required this.username,
    required this.userId,
    required this.email,
    required this.role,
  });

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: FractionallySizedBox(
            widthFactor: screenWidth < 600 ? 0.9 : 0.6, // Responsive width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'WhereBus',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _buildAdminMenuItem(
                  icon: Icons.person,
                  label: 'User Management',
                  onTap: () {
                    // Navigate to User Management
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserManagementScreen(
                          username: widget.username,
                          email: widget.email,
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildAdminMenuItem(
                  icon: Icons.person_pin,
                  label: 'Driver Management',
                  onTap: () {
                    // Navigate to Driver Management
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverManagementScreen(
                          username: widget.username,
                          email: widget.email,
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildAdminMenuItem(
                  icon: Icons.directions_bus,
                  label: 'Bus Status',
                  onTap: () {
                    // Navigate to Bus Status Management
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusStatusScreen(
                          username: widget.username,
                          email: widget.email,
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        role: widget.role,
      ), // เพิ่ม Navigation Bar ที่ด้านล่าง
    );
  }

  Widget _buildAdminMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: Icon(
              icon,
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
