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
  bool _isSendingLocation = false;
  LatLng? _lastSentUserLocation;
  LatLng? _lastBusLocation;
  int _sameLocationCount = 0; // Counter to track same bus location

  @override
  void initState() {
    super.initState();

    // Fetch bus location every 10 seconds
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

  // Fetch user locations
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

                // Avoid adding the user marker if it's already the last sent location
                if (_lastSentUserLocation != null &&
                    _lastSentUserLocation!.latitude == lat &&
                    _lastSentUserLocation!.longitude == lon) {
                  return null;
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
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Color(0xFFEFEFEF)),
                      ),
                    ],
                  ),
                );
              })
              .whereType<Marker>()
              .toList();
        });
      } else {
        print('Failed to fetch user locations: ${response['message']}');
      }
    } catch (e) {
      print('Error fetching user locations: $e');
    }
  }

  // Fetch latest bus location
  Future<void> _fetchLatestBusLocation() async {
    try {
      final response = await apiService.fetchLatestBusLocation();
      if (response['status'] == 'success') {
        Map location = response['location'];
        double lat = location['latitude'];
        double lon = location['longitude'];
        int busId = location['bus_id'];
        String busStatus = location['status'];

        // Check if the location is the same as the previous one
        if (_lastBusLocation != null &&
            _lastBusLocation!.latitude == lat &&
            _lastBusLocation!.longitude == lon) {
          _sameLocationCount++;
        } else {
          _sameLocationCount = 0; // Reset count if location has changed
        }

        // If the location is the same 10 times in a row, set status to 'Offline'
        if (_sameLocationCount >= 10) {
          busStatus = 'Offline';
        }

        setState(() {
          widget.updateLocation(lat, lon);
          _lastBusLocation = LatLng(lat, lon);

          // Adjust the marker for the bus
          _busMarker = Marker(
            width: 60.0,
            height: 60.0,
            point: LatLng(lat + 0.0001, lon + 0.0001), // Slight shift
            builder: (ctx) => Column(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: busStatus == 'Online'
                      ? Colors.green
                      : Colors.red, // Marker color based on status
                  size: 30.0,
                ),
                Text(
                  'Bus ID: $busId',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        });

        _removeBusMarkerTimer?.cancel(); // Cancel bus marker removal if updated
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

  // Static markers for bus ID 2, 3, 4, 5
  List<Marker> _getStaticBusMarkers() {
    return [
      Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(17.289014, 104.111125), // Bus ID 2 (Offline)
        builder: (ctx) => Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.red,
              size: 30.0,
            ),
            Text(
              'Bus ID: 2',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(17.287491, 104.112630), // Bus 3 (Online)
        builder: (ctx) => Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.green,
              size: 30.0,
            ),
            Text(
              'Bus ID: 3',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(17.288904, 104.107397), // Bus ID 4 (Online)
        builder: (ctx) => Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.green,
              size: 30.0,
            ),
            Text(
              'Bus ID: 4',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Handle location permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่า location services ถูกเปิดใช้งานหรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    // ตรวจสอบและขออนุญาตใช้งานตำแหน่งที่ตั้ง
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

  // Send user location
  Future<void> _sendUserLocation() async {
    if (_isSendingLocation) return;

    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isSendingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      if (_lastSentUserLocation != null &&
          _lastSentUserLocation!.latitude == userLatitude &&
          _lastSentUserLocation!.longitude == userLongitude) {
        print('Position has not changed. Skipping send.');
        return;
      }

      final response = await apiService.sendUserLocation(
          widget.userId, userLatitude, userLongitude);

      if (response['status'] == 'success') {
        _lastSentUserLocation = LatLng(userLatitude, userLongitude);

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
                      child: const Text(
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
            _lastSentUserLocation = null;
          });
        });
      } else {
        print('Failed to send user location: ${response['message']}');
      }
    } catch (e) {
      print('Error sending user location: $e');
    } finally {
      setState(() {
        _isSendingLocation = false;
      });
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
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate
            ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_busMarker != null) _busMarker!,
                ..._getStaticBusMarkers(), // Add static markers
                ..._userMarkers,
              ],
            ),
          ],
        ),
        if (widget.role != 'driver')
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isSendingLocation ? null : _sendUserLocation,
                label: const Icon(Icons.send, color: Color(0xFFFFFFFF)),
                icon: const Text(
                  'Send location',
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40534C),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
