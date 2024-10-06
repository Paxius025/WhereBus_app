import 'package:flutter/material.dart';
import 'package:wherebus_app/widgets/location_map.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart';
import 'package:wherebus_app/services/api_service.dart';

class MainScreen extends StatefulWidget {
  final String role;
  final String username;
  final int userId;

  MainScreen(
      {required this.role, required this.username, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _latitude = '';
  String _longitude = '';
  String _currentUsername = '';
  String _currentEmail = '';

  final ApiService apiService = ApiService();

  // ฟังก์ชันสำหรับอัปเดตตำแหน่งจาก location_map.dart
  void updateLocation(double lat, double lon) {
    setState(() {
      _latitude = lat.toString();
      _longitude = lon.toString();
    });
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้ปัจจุบัน
  Future<void> _fetchUserProfile() async {
    try {
      final response = await apiService.getUserProfile(widget.userId);
      if (response['status'] == 'success') {
        setState(() {
          _currentUsername = response['username'];
          _currentEmail = response['email'];
        });
      } else {
        print('Failed to fetch user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // ฟังก์ชัน refreshLocation สำหรับรีเฟรชตำแหน่ง
  void refreshLocation() {
    print('Refreshing locations...');
    // คุณสามารถเพิ่มโค้ดที่ใช้ในการรีเฟรชข้อมูลได้ที่นี่
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WhereBus'),
            if (_latitude.isNotEmpty && _longitude.isNotEmpty)
              Text(
                'Bus Location: Lat: $_latitude, Lon: $_longitude', // แสดงตำแหน่งรถบัส
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${widget.username} (${widget.role})',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LocationMap(
              username: _currentUsername,
              role: widget.role,
              userId: widget.userId,
              updateLocation: updateLocation, // รับตำแหน่งรถบัสจาก LocationMap
            ),
          ),
        ],
      ),
      // ส่งข้อมูลไปยัง NavigationBarWidget
      bottomNavigationBar: NavigationBarWidget(
        username: _currentUsername,
        email: _currentEmail,
        userId: widget.userId,
        refreshLocation: refreshLocation,
        role: widget.role, // ส่งฟังก์ชัน refreshLocation
      ),
    );
  }
}
