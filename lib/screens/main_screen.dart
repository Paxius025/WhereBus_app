import 'package:flutter/material.dart';
import 'package:wherebus_app/widgets/location_map.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wherebus_app/screens/edit_profile_screen.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';

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
  LatLng? _initialBusLocation;
  List<Marker> _userMarkers = [];

  final ApiService apiService = ApiService();

  void updateLocation(double lat, double lon) {
    setState(() {
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
          username: _currentUsername,
          email: _currentEmail,
          userId: widget.userId,
          role: widget.role,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentUsername = result['username'];
        _currentEmail = result['email'];
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await apiService.getUserProfile(widget.userId);
      if (response['status'] == 'success') {
        setState(() {
          _currentUsername = response['username'];
          _currentEmail = response['email'];
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

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
    } else {
      print('Location permission granted.');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Icon icon;

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
      body: Stack(
        children: [
          LocationMap(
            username: _currentUsername,
            role: widget.role,
            userId: widget.userId,
            updateLocation: updateLocation,
            initialBusLocation: _initialBusLocation,
            userMarkers: _userMarkers,
          ),
          // Overlay for the title and user info
          Positioned(
            top: 20, // Adjust this to position it as needed
            left: 16,
            right: 16,
            child: Container(
              color: Colors.transparent, // Background color if needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StrokeText(
                    text: 'WhereBus',
                    textStyle: GoogleFonts.lilitaOne(
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 3.5,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      icon,
                    ],
                  ),
                ],
              ),
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
