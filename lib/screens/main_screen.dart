import 'package:flutter/material.dart';
import 'package:wherebus_app/widgets/location_map.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // เพิ่มบรรทัดนี้
import 'package:flutter_map/flutter_map.dart';
import 'package:wherebus_app/screens/edit_profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String role;
  final String username;
  final int userId;

  MainScreen(
      {required this.role, required this.username, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _currentUsername = '';
  String _currentEmail = '';
  LatLng? _initialBusLocation; // เก็บตำแหน่งเริ่มต้นของรถบัส
  List<Marker> _userMarkers = []; // เก็บตำแหน่งของผู้ใช้

  final ApiService apiService = ApiService();

  // ฟังก์ชันสำหรับอัปเดตตำแหน่งจาก location_map.dart
  void updateLocation(double lat, double lon) {
    setState(() {
      // อัปเดตตำแหน่งของผู้ใช้
      _userMarkers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(lat, lon),
        builder: (ctx) => Column(
          children: [
            Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 40.0,
            ),
            Text(
              widget.username.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                backgroundColor: Color(0xFFEFEFEF),
              ),
            ),
          ],
        ),
      ));
    });
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          username: _currentUsername, // ใช้ _currentUsername ที่ได้รับจาก API
          email: _currentEmail, // ใช้ _currentEmail ที่ได้รับจาก API
          userId: widget.userId, // ใช้ userId จาก widget
          role: widget.role, // ใช้ role จาก widget
        ),
      ),
    );

    // อัปเดตข้อมูลที่ได้จากหน้าการแก้ไขโปรไฟล์
    if (result != null) {
      setState(() {
        _currentUsername = result['username'];
        _currentEmail = result['email'];
      });
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้ปัจจุบัน
  Future<void> _fetchUserProfile() async {
    try {
      final response = await apiService.getUserProfile(widget.userId);
      if (response['status'] == 'success') {
        setState(() {
          _currentUsername = response['username'];
          _currentEmail = response['email'];
          // กำหนดตำแหน่งเริ่มต้นของรถบัสที่นี่
          double busLatitude = response['bus_latitude'] ?? 0.0;
          double busLongitude = response['bus_longitude'] ?? 0.0;
          _initialBusLocation = LatLng(busLatitude, busLongitude);
        });
      } else {
        print('Failed to fetch user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // ฟังก์ชันสำหรับขออนุญาตตำแหน่ง
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // แจ้งผู้ใช้ว่าต้องไปตั้งค่าอนุญาตตำแหน่ง
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
    } else {
      // อนุญาตให้เข้าถึงตำแหน่ง
      print('Location permission granted.');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _requestLocationPermission(); // เรียกฟังก์ชันเพื่อขออนุญาตตำแหน่ง
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Icon icon;

    // เปรียบเทียบ role เพื่อกำหนดไอคอน
    switch (widget.role) {
      case 'admin':
        icon = const Icon(Icons.handyman, color: Colors.grey);
        break;
      case 'user':
        icon = const Icon(Icons.person, color: Colors.grey);
        break;
      case 'driver':
        icon = const Icon(Icons.directions_bus, color: Colors.grey);
        break;
      default:
        icon = const Icon(Icons.help, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        title: const Column(
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
                SizedBox(width: 8),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8),
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
              updateLocation: updateLocation,
              initialBusLocation:
                  _initialBusLocation, // ส่งตำแหน่งเริ่มต้นไปที่ LocationMap
              userMarkers: _userMarkers, // ส่งตำแหน่งของผู้ใช้ไปที่ LocationMap
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarWidget(
        username: _currentUsername,
        email: _currentEmail,
        userId: widget.userId,
        role: widget.role,
      ),
    );
  }
}
