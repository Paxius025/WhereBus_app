import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:latlong2/latlong.dart'; // Import LatLng for consistency with location_map.dart

class BusStatusScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String role;

  const BusStatusScreen({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
    required this.role,
  });

  @override
  _BusStatusScreenState createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> buses = [];
  bool _isLoading = true;
  String _errorMessage = '';
  LatLng? _lastBusLocation; // Add last bus location for status consistency
  int _sameLocationCount = 0; // Counter to track same bus location

  @override
  void initState() {
    super.initState();
    _fetchBusLocations();
  }

  Future<void> _fetchBusLocations() async {
    try {
      final response = await apiService.fetchLatestBusLocation();
      if (response['status'] == 'success') {
        setState(() {
          buses = [
            response['location'] ?? {}
          ]; // Handle case where response['location'] is null
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load bus locations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching bus locations: $e';
        _isLoading = false;
      });
    }
  }

  // Reuse the same logic from location_map.dart to determine bus status color
  String _getBusStatus(Map location) {
    double lat = location['latitude'];
    double lon = location['longitude'];

    // Check if the location is the same as the previous one
    if (_lastBusLocation != null &&
        _lastBusLocation!.latitude == lat &&
        _lastBusLocation!.longitude == lon) {
      _sameLocationCount++;
    } else {
      _sameLocationCount = 0; // Reset count if location has changed
    }

    // If the location is the same 60 times in a row, set status to 'Offline'
    if (_sameLocationCount >= 60) {
      return 'Offline';
    }

    _lastBusLocation = LatLng(lat, lon);
    return 'Online';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // Set background color
        title: const Text('Bus Status'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFFFFF), // Set background color
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      final bus = buses[index];
                      String busId = bus['bus_id']?.toString() ?? 'N/A';
                      String status = _getBusStatus(bus);
                      Color statusColor =
                          status == 'Online' ? Colors.green : Colors.red;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_bus,
                                color:
                                    statusColor, // Bus icon color based on status
                                size: screenWidth *
                                    0.1, // Responsive size for bus icon
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bus ID: $busId',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth *
                                            0.05, // Responsive font size
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Status: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color:
                                                statusColor, // Status text color
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
