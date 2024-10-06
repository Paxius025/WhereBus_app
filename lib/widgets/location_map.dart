import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationMap extends StatefulWidget {
  final String role;
  final int userId;
  final Function(double, double) updateLocation;

  const LocationMap({
    super.key,
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

  @override
  void initState() {
    super.initState();
    _fetchLatestBusLocation();

    if (widget.role == 'driver') {
      _fetchUserLocations();
    }

    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (widget.role == 'driver') {
        _fetchUserLocations();
      } else {
        _sendUserLocation();
      }
    });
  }

  @override
  void dispose() {
    _markerTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserLocations() async {
    try {
      final response = await apiService.fetchUserLocations('driver');

      if (response['status'] == 'success') {
        List locations = response['locations'];

        setState(() {
          _userMarkers = locations.map((location) {
            double lat = double.parse(location['latitude']);
            double lon = double.parse(location['longitude']);
            int userId = location['user_id'];
            String username = location['username'];

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
                    username.toUpperCase(), // แปลงเป็นตัวพิมพ์ใหญ่
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold, // ทำให้ตัวหนา
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

  Future<void> _sendUserLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      final response = await apiService.sendUserLocation(
          widget.userId, userLatitude, userLongitude);

      if (response['status'] == 'success') {
        setState(() {
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

        _markerTimer?.cancel();
        _markerTimer = Timer(Duration(minutes: 2), () {
          setState(() {
            _userMarkers.removeLast();
          });
        });
      }
    } catch (e) {
      print('Error sending user location: $e');
    }
  }

  Future<void> _fetchLatestBusLocation() async {
    try {
      final response = await apiService.fetchLatestBusLocation();

      if (response['status'] == 'success') {
        Map location = response['location'];
        double lat = location['latitude'];
        double lon = location['longitude'];
        int busId = location['bus_id'];

        setState(() {
          widget.updateLocation(lat, lon);

          _busMarker = Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lon),
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
      }
    } catch (e) {
      print('Error fetching bus location: $e');
    }
  }

  // ฟังก์ชันสำหรับการรีเฟรชเมื่อกดปุ่มใน navigation bar
  void _refreshLocation() {
    if (widget.role == 'driver') {
      _fetchUserLocations();
    } else {
      _sendUserLocation();
    }
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
            bottom: 50,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: _sendUserLocation,
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
