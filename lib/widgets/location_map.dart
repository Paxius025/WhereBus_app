import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/services/api_service.dart';

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
  Marker? _busMarker; // ใช้แค่ marker เดียว
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchLatestBusLocation(); // ดึงข้อมูลแค่ตำแหน่งเดียว
  }

  Future<void> _fetchLatestBusLocation() async {
    try {
      final response = await apiService.fetchLatestBusLocation();
      if (response['status'] == 'success') {
        Map location = response['location'];
        setState(() {
          double lat = location['latitude']; // ใช้ค่า double โดยตรง
          double lon = location['longitude']; // ใช้ค่า double โดยตรง
          int busId = location['bus_id']; // ใช้ bus_id เป็น int
          widget.updateLocation(
              lat, lon); // ส่งตำแหน่งกลับไปยัง MainScreen ผ่าน callback

          // สร้าง marker สำหรับตำแหน่งล่าสุด
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
                  'Bus ID: ${busId.toString()}', // แปลง bus_id เป็น String ก่อนแสดงผล
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
        print('Failed to fetch bus location');
      }
    } catch (e) {
      print('Error fetching bus location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(17.280525, 104.123622), // ตำแหน่ง default
        zoom: 14.5,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _busMarker != null
              ? [_busMarker!]
              : [], // แสดง marker ตำแหน่งล่าสุด
        ),
      ],
    );
  }
}
