import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/widgets/static/admin_dashboard/static_bus_status.dart'; // Import the static bus status

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
  List<Map<String, dynamic>> buses = []; // Initialize an empty list for buses
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBusLocations(); // Fetch bus locations from API
  }

  Future<void> _fetchBusLocations() async {
    try {
      final response = await apiService.fetchLatestBusLocation();
      if (response['status'] == 'success') {
        // Add the bus data from API response to the existing buses list
        setState(() {
          buses.add({
            'bus_id': response['location']['bus_id'],
            'status': response['location']['status']
          });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Get static bus data
    List<Map<String, dynamic>> mockBuses = getStaticBusStatus(); // Use the static data

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
                    itemCount: buses.length +
                        mockBuses.length, // Count both API and mock buses
                    itemBuilder: (context, index) {
                      Map<String, dynamic> bus;
                      if (index < buses.length) {
                        bus = buses[index]; // Get bus from API
                      } else {
                        bus = mockBuses[
                            index - buses.length]; // Get bus from mock data
                      }

                      String busId = bus['bus_id']?.toString() ?? 'N/A';
                      String status = bus['status'] ??
                          'Offline'; // Use status from API or Mock data
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
