import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart'; // เพิ่ม geolocator
import 'dart:async'; // สำหรับใช้ Timer

class LocationMap extends StatefulWidget {
  final String role;
  final int userId;
  final Function(double, double)
      updateLocation; // เพิ่ม parameter สำหรับรับ callback

  const LocationMap({
    super.key,
    required this.role,
    required this.userId,
    required this.updateLocation, // ทำให้ updateLocation เป็น parameter จำเป็น
  });

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  Marker? _busMarker; // ใช้แค่ marker เดียวสำหรับรถบัส
  List<Marker> _userMarkers = []; // ใช้สำหรับแสดงตำแหน่งของผู้ใช้หลายคน
  final ApiService apiService = ApiService();
  Timer? _markerTimer; // Timer สำหรับลบ marker หลัง 2 นาที
  Timer? _refreshTimer; // Timer สำหรับรีเฟรชทุกๆ 20 นาที

  @override
  void initState() {
    super.initState();
    _fetchLatestBusLocation(); // ดึงข้อมูลตำแหน่งรถบัสล่าสุด

    if (widget.role == 'driver') {
      _fetchUserLocations(); // ถ้าเป็น driver ให้ดึงตำแหน่งของผู้ใช้ทั้งหมด
    }

    // ตั้ง Timer เพื่อรีเฟรชข้อมูลทุกๆ 20 นาที
    _refreshTimer = Timer.periodic(Duration(minutes: 20), (timer) {
      if (widget.role == 'driver') {
        _fetchUserLocations(); // รีเฟรชตำแหน่งของผู้ใช้ทุกๆ 20 นาที
      } else {
        _sendUserLocation(); // ส่งตำแหน่งของผู้ใช้ทุกๆ 20 นาที
      }
    });
  }

  @override
  void dispose() {
    _markerTimer?.cancel(); // ยกเลิก timer เมื่อตัว component ถูกยกเลิก
    _refreshTimer?.cancel(); // ยกเลิก refresh timer
    super.dispose();
  }

  // ฟังก์ชันดึงตำแหน่งของผู้ใช้ทั้งหมดสำหรับ driver
  Future<void> _fetchUserLocations() async {
    try {
      print('Fetching user locations...');
      final response = await apiService.fetchUserLocations('driver');
      print('API response for user locations: $response');

      if (response['status'] == 'success') {
        List locations = response['locations'];
        print('User locations received: $locations');

        setState(() {
          _userMarkers = locations.map((location) {
            // แปลง String เป็น double
            double lat = double.parse(location['latitude']);
            double lon = double.parse(location['longitude']);
            int userId = location['user_id'];
            String username = location['username']; // รับชื่อผู้ส่ง

            print(
                'User marker: Lat: $lat, Lon: $lon, User ID: $userId, Username: $username');

            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lat, lon), // ใช้ LatLng ด้วยค่า double
              builder: (ctx) => Column(
                children: [
                  Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                  Text(
                    'Sent by: $username', // แสดงชื่อผู้ส่ง
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        });
      } else {
        print('Failed to fetch user locations: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user locations: $e');
    }
  }

  // ฟังก์ชันส่งตำแหน่งผู้ใช้ไปยัง API และแสดง marker ผู้ใช้เป็นเวลา 2 นาที
  Future<void> _sendUserLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      print('Location permission denied');
      return;
    }

    try {
      // ดึงตำแหน่งปัจจุบันของผู้ใช้
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      print('Sending user location: Lat: $userLatitude, Lon: $userLongitude');

      final response = await apiService.sendUserLocation(
          widget.userId, userLatitude, userLongitude);
      print('API response for sending location: $response');

      if (response['status'] == 'success') {
        setState(() {
          // ปักหมุดตำแหน่งผู้ใช้บนแผนที่
          _userMarkers.add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(userLatitude, userLongitude),
              builder: (ctx) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          );
        });

        print('User location marker added on map');

        // ตั้งเวลา 2 นาทีเพื่อลบ marker ผู้ใช้
        _markerTimer?.cancel(); // ยกเลิก timer ก่อนหน้า (ถ้ามี)
        _markerTimer = Timer(Duration(minutes: 2), () {
          setState(() {
            _userMarkers.removeLast(); // ลบ marker ผู้ใช้หลัง 2 นาที
            print('User location marker removed after 2 minutes');
          });
        });
      } else {
        print('Failed to send user location: ${response['message']}');
      }
    } catch (e) {
      print('Error sending user location: $e');
    }
  }

  // ฟังก์ชันขอสิทธิ์การเข้าถึงตำแหน่ง
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่า GPS เปิดใช้งานหรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false; // ถ้า GPS ไม่เปิดใช้งาน
    }

    // ขอสิทธิ์การเข้าถึงตำแหน่ง
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied by user.');
        return false; // ถ้าผู้ใช้ไม่ให้สิทธิ์การเข้าถึง
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever.');
      return false; // ถ้าผู้ใช้ปฏิเสธการเข้าถึงตลอดไป
    }

    return true; // ถ้าเปิดใช้งานและได้รับสิทธิ์การเข้าถึง
  }

  // ดึงตำแหน่งล่าสุดของรถบัส
  Future<void> _fetchLatestBusLocation() async {
    try {
      print('Fetching latest bus location...');
      final response = await apiService.fetchLatestBusLocation();
      print('API response for bus location: $response');

      if (response['status'] == 'success') {
        Map location = response['location'];
        double lat = location['latitude'];
        double lon = location['longitude'];
        int busId = location['bus_id'];

        print('Bus location: Lat: $lat, Lon: $lon, Bus ID: $busId');

        setState(() {
          widget.updateLocation(
              lat, lon); // ส่งตำแหน่งกลับไปยัง MainScreen ผ่าน callback

          // สร้าง marker สำหรับตำแหน่งรถบัสล่าสุด
          _busMarker = Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lon), // ใช้ LatLng ด้วยค่า double
            builder: (ctx) => Column(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Colors.green,
                  size: 40.0,
                ),
                Text(
                  'Bus ID: $busId',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        });
      } else {
        print('Failed to fetch bus location: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching bus location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(17.280525, 104.123622), // ตำแหน่ง default
            zoom: 14.5,
            maxZoom: 18.0, // เพิ่มข้อจำกัดการซูมสูงสุด
            onPositionChanged: (MapPosition position, bool hasGesture) {
              // ตรวจสอบว่าการซูมไม่เกินค่าที่กำหนด
              if (position.zoom! > 16.0) {
                print('Zoom limit reached');
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_busMarker != null) _busMarker!, // แสดงตำแหน่งรถบัส
                ..._userMarkers, // แสดงตำแหน่งของผู้ใช้ทั้งหมด
              ],
            ),
          ],
        ),
        if (widget.role != 'driver') // ซ่อนปุ่มส่งตำแหน่งสำหรับ driver
          Positioned(
            bottom: 50,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: _sendUserLocation, // เมื่อกดปุ่มจะส่งตำแหน่งผู้ใช้
              icon: Icon(Icons.send),
              label: Text('Send location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
