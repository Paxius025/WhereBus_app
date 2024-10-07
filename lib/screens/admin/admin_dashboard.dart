// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_status_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  final int userId;

  const AdminDashboardScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              label: 'User',
              onTap: () {
                // Navigate to User Management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildAdminMenuItem(
              icon: Icons.person_pin,
              label: 'Driver',
              onTap: () {
                // Navigate to Driver Management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildAdminMenuItem(
              icon: Icons.directions_bus,
              label: 'Tracking Device',
              onTap: () {
                // Navigate to Bus Status Management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStatusScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
