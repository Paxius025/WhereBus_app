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
  List<Marker> _markers = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchBusLocations();
  }

  Future<void> _fetchBusLocations() async {
    try {
      final response = await apiService.fetchAllBusLocations();
      if (response['status'] == 'success') {
        List locations = response['locations'];
        setState(() {
          _markers = locations.map((location) {
            double lat = double.parse(location['latitude']);
            double lon = double.parse(location['longitude']);
            widget.updateLocation(
                lat, lon); // ส่งตำแหน่งรถบัสกลับไปยัง MainScreen ผ่าน callback
            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lat, lon),
              builder: (ctx) => const Icon(
                Icons.directions_bus,
                color: Colors.green,
                size: 40.0,
              ),
            );
          }).toList();
        });
      } else {
        print('Failed to fetch bus locations');
      }
    } catch (e) {
      print('Error fetching bus locations: $e');
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
          markers: _markers, // แสดงตำแหน่งรถบัสที่ fetch จาก API
        ),
      ],
    );
  }
}
