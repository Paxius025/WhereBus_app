// lib/screens/admin/bus_status_screen.dart
import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart'; // Import NavigationBarWidget

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
          buses = [response['location'] ?? {}]; // จัดการกรณี response['location'] เป็น null
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bus Status'),
        centerTitle: true,
      ),
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
                      String busId = bus['bus_id']?.toString() ?? 'N/A'; // กำหนดค่าเริ่มต้นหาก bus_id เป็น null
                      String timestamp = bus['timestamp'] ?? ''; // กำหนดค่าเริ่มต้นหาก timestamp เป็น null

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_bus,
                                color: Colors.orange,
                                size: screenWidth * 0.1, // Responsive size for bus icon
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
                                        fontSize: screenWidth * 0.05, // Responsive font size
                                      ),
                                    ),
                                    SizedBox(height: 8),
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
                                          _getBusStatus(timestamp),
                                          style: TextStyle(
                                            color: _getBusStatus(timestamp) == 'Online'
                                                ? Colors.green
                                                : Colors.red,
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
      bottomNavigationBar: NavigationBarWidget(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        role: widget.role,
      ), // เพิ่ม NavigationBarWidget
    );
  }

  String _getBusStatus(String timestamp) {
    if (timestamp.isEmpty) {
      return 'Offline'; // กรณี timestamp ไม่มีข้อมูล ให้ถือว่าเป็น Offline
    }
    try {
      DateTime lastUpdate = DateTime.parse(timestamp);
      Duration difference = DateTime.now().difference(lastUpdate);
      if (difference.inMinutes <= 2) {
        return 'Online';
      } else {
        return 'Offline';
      }
    } catch (e) {
      return 'Offline'; // ถ้า parsing ไม่สำเร็จ ให้ถือว่าเป็น Offline
    }
  }
}
