import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:wherebus_app/widgets/send_location_button.dart';

class LocationMap extends StatefulWidget {
  final String role;
  final String username;
  final int userId;
  final Function(double, double) updateLocation;
  final LatLng? initialBusLocation; // เพิ่มตัวแปรนี้
  final List<Marker> userMarkers;

  const LocationMap({
    super.key,
    required this.username,
    required this.role,
    required this.userId,
    required this.updateLocation,
    this.initialBusLocation,
    required this.userMarkers, // รับค่าผู้ใช้
  });

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Marker? _busMarker;
  List<Marker> _userMarkers = [];
  final ApiService apiService = ApiService();
  Timer? _markerTimer;
  Timer? _refreshTimer;
  Timer? _removeBusMarkerTimer;
  bool _isSendingLocation = false;
  LatLng? _lastSentUserLocation;
  final MapController _mapController = MapController(); // ควบคุมแผนที่

  @override
  void initState() {
    super.initState();

    // ตั้งค่าตำแหน่งเริ่มต้นถ้ามี
    if (widget.initialBusLocation != null) {
      _busMarker = Marker(
        width: 40.0,
        height: 40.0,
        point: widget.initialBusLocation!, // ใช้ตำแหน่งที่ได้รับ
        builder: (ctx) => Column(
          children: [
            Icon(
              Icons.directions_bus,
              color: Colors.green, // สีของ bus marker
              size: 15.0,
            ),
            Text(
              'Bus Location',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      );
    }

    // Fetch bus location every 5 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
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
                  builder: (ctx) {
                    // Get the current zoom level
                    double zoom = _mapController.zoom;
                    double iconSize =
                        20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
                    double textSize =
                        10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: iconSize,
                        ),
                        Text(
                          username.toUpperCase(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                            backgroundColor: const Color(0xFFEFEFEF),
                          ),
                        ),
                      ],
                    );
                  },
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
        String busStatus = location['status']; // Use status from API

        setState(() {
          widget.updateLocation(lat, lon);

          // Adjust the marker for the bus
          _busMarker = Marker(
            width: 45.0,
            height: 45.0,
            point: LatLng(lat, lon), // Slight shift
            builder: (ctx) {
              // Get the current zoom level
              double zoom = _mapController.zoom;
              double iconSize = 20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
              double textSize =
                  10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

              return Column(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: busStatus == 'Online'
                        ? Colors.green
                        : Colors.red, // Use status from API for marker color
                    size: iconSize,
                  ),
                  Text(
                    'Bus $busId',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: textSize,
                    ),
                  ),
                ],
              );
            },
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
        width: 45.0,
        height: 45.0,
        point: LatLng(17.289014, 104.111125), // Bus ID 2 (Offline)
        builder: (ctx) {
          // Get the current zoom level
          double zoom = _mapController.zoom;
          double iconSize = 20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
          double textSize = 10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

          return Column(
            children: [
              Icon(
                Icons.directions_bus,
                color: Colors.red,
                size: iconSize,
              ),
              Text(
                'Bus 2',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textSize,
                ),
              ),
            ],
          );
        },
      ),
      Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(17.287491, 104.112630), // Bus 3 (Online)
        builder: (ctx) {
          // Get the current zoom level
          double zoom = _mapController.zoom;
          double iconSize = 20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
          double textSize = 10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

          return Column(
            children: [
              Icon(
                Icons.directions_bus,
                color: Colors.green,
                size: iconSize,
              ),
              Text(
                'Bus 3',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textSize,
                ),
              ),
            ],
          );
        },
      ),
      Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(17.288904, 104.107397), // Bus ID 4 (Online)
        builder: (ctx) {
          // Get the current zoom level
          double zoom = _mapController.zoom;
          double iconSize = 20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
          double textSize = 10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

          return Column(
            children: [
              Icon(
                Icons.directions_bus,
                color: Colors.green,
                size: iconSize,
              ),
              Text(
                'Bus 4',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textSize,
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  // Handle location permission
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
              width: 50.0,
              height: 50.0,
              point: _lastSentUserLocation!,
              builder: (ctx) {
                // Get the current zoom level
                double zoom = _mapController.zoom;
                double iconSize =
                    20.0 * (zoom / 14); // ปรับขนาดไอคอนตามระดับซูม
                double textSize =
                    10.0 * (zoom / 14); // ปรับขนาดข้อความตามระดับซูม

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: iconSize,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 5), // ระยะห่างระหว่างไอคอนและข้อความ
                      child: Text(
                        'You',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: textSize,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
    super.build(context);
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              center: LatLng(17.280525, 104.123622),
              zoom: 14.5,
              maxZoom: 18.0,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_busMarker != null) _busMarker!,
                ..._userMarkers,
                ..._getStaticBusMarkers(), // เพิ่ม static markers ที่นี่
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
              child: SendLocationButton(
                isSendingLocation: _isSendingLocation,
                onSendLocation: _sendUserLocation,
              ),
            ),
          ),
      ],
    );
  }
}
