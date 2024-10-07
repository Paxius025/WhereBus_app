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
    Icon icon;

    // เปรียบเทียบ role เพื่อกำหนดไอคอน
    switch (widget.role) {
      case 'admin':
        icon = Icon(Icons.handyman, color: Colors.red);
        break;
      case 'user':
        icon = Icon(Icons.person, color: Colors.blue);
        break;
      case 'driver':
        icon = Icon(Icons.directions_bus, color: Colors.green);
        break;
      default:
        icon = Icon(Icons.help, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WhereBus'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // แสดง Role ก่อน
                Text(
                  '${widget.role} : '.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.black, // สีของบทบาท
                  ),
                ),
                SizedBox(width: 8), // ระยะห่างระหว่างบทบาทและชื่อผู้ใช้
                // แสดง Username
                Text(
                  '${widget.username}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // สีของชื่อผู้ใช้
                  ),
                ),
                SizedBox(width: 8), // ระยะห่างระหว่างชื่อผู้ใช้และไอคอน
                // แสดง Icon
                icon,
              ],
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
        role: widget.role, // ส่งฟังก์ชัน refreshLocation
      ),
    );
  }
}
