import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationMap extends StatefulWidget {
  final String role;
  final String username;
  final int userId;
  final Function(double, double) updateLocation;

  const LocationMap({
    super.key,
    required this.username,
    required this.role,
    required this.userId,
    required this.updateLocation,
  });

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  Marker? _busMarker;
  List<Marker> _userMarkers = [];
  final ApiService apiService = ApiService();
  Timer? _markerTimer;
  Timer? _refreshTimer;
  Timer? _removeBusMarkerTimer;
  bool _isSendingLocation = false; // ป้องกันการส่งข้อมูลซ้ำ
  LatLng? _lastSentUserLocation; // เก็บตำแหน่งผู้ใช้ที่ส่งล่าสุด

  @override
  void initState() {
    super.initState();

    // ดึงข้อมูลตำแหน่งรถบัสทุกๆ 10 วินาที
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchLatestBusLocation();
    });

    if (widget.role == 'driver') {
      _fetchUserLocations();
    }
  }

  @override
  void dispose() {
    _markerTimer?.cancel();
    _refreshTimer?.cancel();
    _removeBusMarkerTimer?.cancel();
    super.dispose();
  }

  // ฟังก์ชันสำหรับการดึงตำแหน่งผู้ใช้ทั้งหมด
  Future<void> _fetchUserLocations() async {
    try {
      final response = await apiService.fetchUserLocations('driver');

      if (response['status'] == 'success') {
        List locations = response['locations'];

        setState(() {
          _userMarkers = locations
              .map((location) {
                double lat = double.parse(location['latitude']);
                double lon = double.parse(location['longitude']);
                String username = location['username'];

                // ถ้ามีตำแหน่งผู้ใช้ล่าสุดที่เพิ่งส่ง ให้ข้ามการลบตำแหน่งนี้ออกไป
                if (_lastSentUserLocation != null &&
                    _lastSentUserLocation!.latitude == lat &&
                    _lastSentUserLocation!.longitude == lon) {
                  return null; // ไม่ต้องเพิ่มตำแหน่งนี้ซ้ำ
                }

                return Marker(
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
                        username.toUpperCase(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            backgroundColor: const Color(0xFFEFEFEF)),
                      ),
                    ],
                  ),
                );
              })
              .whereType<Marker>()
              .toList(); // ลบรายการที่ null ออก
        });
      } else {
        print('Failed to fetch user locations: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user locations: $e');
    }
  }

  // ฟังก์ชันสำหรับการดึงตำแหน่งรถบัสล่าสุด
  Future<void> _fetchLatestBusLocation() async {
    try {
      final response = await apiService.fetchLatestBusLocation();

      if (response['status'] == 'success') {
        Map location = response['location'];
        double lat = location['latitude'];
        double lon = location['longitude'];
        int busId = location['bus_id'];
        String busStatus = location['status']; // อ่านสถานะของรถบัส

        print(
            'Bus fetch successfull [Bus ID :$busId :latitude : $lat, longitude  : $lon]');

        setState(() {
          widget.updateLocation(lat, lon);

          // ปรับให้ marker ของรถไม่ซ้อนกับผู้ใช้ (shift ตำแหน่งเล็กน้อย)
          _busMarker = Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat + 0.0001, lon + 0.0001), // Shift เล็กน้อย
            builder: (ctx) => Column(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: busStatus == 'Online'
                      ? Colors.green
                      : Colors.red, // สีขึ้นกับสถานะ Online หรือ Offline
                  size: 40.0,
                ),
                Text(
                  'Bus ID: $busId',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  busStatus, // แสดงสถานะ Online/Offline
                  style: TextStyle(
                    color: busStatus == 'Online' ? Colors.green : Colors.red,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        });

        _removeBusMarkerTimer?.cancel(); // ยกเลิกการลบ Marker ถ้าตำแหน่งได้รับ
      }
    } catch (e) {
      print('Error fetching bus location: $e');
    }

    _removeBusMarkerTimer = Timer(Duration(seconds: 58), () {
      setState(() {
        _busMarker = null;
      });
      print('No bus location received within 60 seconds. Marker removed.');
    });
  }

  // ฟังก์ชันสำหรับการส่งตำแหน่งผู้ใช้ (เฉพาะตอนกดปุ่มเท่านั้น)
  Future<void> _sendUserLocation() async {
    if (_isSendingLocation) return; // ป้องกันการส่งซ้ำ

    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isSendingLocation = true; // ตั้งสถานะกำลังส่งข้อมูล
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // ถ้าเป็นตำแหน่งเดียวกันกับที่ส่งล่าสุด จะไม่ส่งซ้ำ
      if (_lastSentUserLocation != null &&
          _lastSentUserLocation!.latitude == userLatitude &&
          _lastSentUserLocation!.longitude == userLongitude) {
        print('Position has not changed. Skipping send.');
        return;
      }

      final response = await apiService.sendUserLocation(
          widget.userId, userLatitude, userLongitude);

      if (response['status'] == 'success') {
        _lastSentUserLocation =
            LatLng(userLatitude, userLongitude); // เก็บตำแหน่งล่าสุดที่ส่ง

        setState(() {
          _userMarkers.add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: _lastSentUserLocation!,
              builder: (ctx) => Stack(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      child: Text(
                        'You',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });

        print(
            '${widget.username}: location sent successfully: Lat: $userLatitude, Lon: $userLongitude');

        _markerTimer?.cancel();
        _markerTimer = Timer(Duration(minutes: 2), () {
          setState(() {
            _userMarkers.removeWhere((marker) =>
                marker.point.latitude == userLatitude &&
                marker.point.longitude == userLongitude);
            _lastSentUserLocation = null; // รีเซ็ตตำแหน่งที่ส่ง
          });
        });
      } else {
        print('Failed to send user location: ${response['message']}');
      }
    } catch (e) {
      print('Error sending user location: $e');
    } finally {
      setState(() {
        _isSendingLocation = false; // รีเซ็ตสถานะหลังจากส่งเสร็จ
      });
    }
  }

  // ฟังก์ชันสำหรับการขอสิทธิ์การเข้าถึงตำแหน่ง
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied by user.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever.');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(17.280525, 104.123622),
            zoom: 14.5,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_busMarker != null) _busMarker!,
                ..._userMarkers,
              ],
            ),
          ],
        ),
        if (widget.role != 'driver')
          Positioned(
            bottom: 50, // ตำแหน่งปุ่มอยู่ห่างจากขอบล่าง 50px
            left: 0, // ปุ่มจะอยู่ตรงกลาง
            right: 0, // ทำให้ปุ่มอยู่ตรงกลางระหว่างซ้ายและขวา
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isSendingLocation
                    ? null
                    : _sendUserLocation, // ปิดปุ่มขณะส่ง
                label: const Icon(Icons.send,
                    color: Color(0xFFFFFFFF)), // ไอคอนอยู่หลังข้อความ
                icon: const Text(
                  'Send location', // ข้อความอยู่หน้าข้อความ
                  style: TextStyle(
                      color: Color(0xFFFFFFFF)), // สีของตัวหนังสือ #FFFFFF
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF40534C), // สีพื้นหลัง #40534C
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical:
                          8), // เพิ่มความสูงอีก 5px (จากเดิม 12px เป็น 17px)
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // ทำให้ปุ่มมีขอบโค้งมน
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
