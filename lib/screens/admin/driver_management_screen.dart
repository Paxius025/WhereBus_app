//driver_management_screen.dart
import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';

class DriverManagementScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String role;

  const DriverManagementScreen({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
    required this.role,
  });

  @override
  _DriverManagementScreenState createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> drivers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 0;
  final int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      final response = await apiService.getDrivers();
      if (response['status'] == 'success') {
        setState(() {
          drivers = List<Map<String, dynamic>>.from(response['drivers']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load drivers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching drivers: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDriver(int driverId) async {
    final response = await apiService.deleteDriver(driverId);
    if (response['status'] == 'success') {
      setState(() {
        drivers.removeWhere((driver) => driver['id'] == driverId);
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Failed to delete driver';
      });
    }
  }

  Future<void> _addDriver(String username, String password) async {
    try {
      final response = await apiService.addDriver(username, password);
      if (response['status'] == 'success') {
        _fetchDrivers(); // รีเฟรชรายการคนขับหลังจากเพิ่มสำเร็จ
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to add driver';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding driver: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Driver Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: screenWidth,
                            child: _buildDriverTable(screenWidth),
                          ),
                        ),
                      ),
                      _buildPaginationControls(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDriverTable(double screenWidth) {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = (_currentPage + 1) * _itemsPerPage > drivers.length
        ? drivers.length
        : (_currentPage + 1) * _itemsPerPage;

    List<Map<String, dynamic>> currentItems =
        drivers.sublist(startIndex, endIndex);

    return // การแสดงหัวคอลัมน์ ID, USERNAME, ACTION ให้อยู่ตรงกลาง
        // การแสดงหัวคอลัมน์ ID, USERNAME, ACTION และเนื้อหาให้อยู่ตรงกลางในพื้นที่ของตนเอง
        DataTable(
      headingRowColor: MaterialStateProperty.all(
          const Color(0xFF40534C)), // พื้นหลังสีเขียวสำหรับหัวตารางทั้งหมด
      columnSpacing: 10,
      columns: [
        DataColumn(
          label: Expanded(
            child: Center(
              child: Text(
                'ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(
              child: Text(
                'USERNAME',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(
              child: Text(
                'ACTION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
      rows: currentItems
          .map(
            (driver) => DataRow(
              cells: [
                DataCell(
                  Center(
                    child: Text(
                      driver['id'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F7777),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      driver['username'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F7777),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Color(0xFF1A3636), size: 20),
                          onPressed: () {
                            _showRenameDialog(driver['id'], driver['username']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            _showDeleteConfirmation(driver['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  void _showRenameDialog(int driverId, String currentUsername) {
    TextEditingController usernameController =
        TextEditingController(text: currentUsername);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A3636), // พื้นหลังสีเข้มของ Popup
        title: const Text('Rename Driver',
            style: TextStyle(color: Colors.white)), // ตัวหนังสือสีขาว
        content: TextField(
          controller: usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Username',
            labelStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color(0xFF40534C), // พื้นหลังของ TextField
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await apiService.updateDriver(
                  driverId, usernameController.text, '');
              Navigator.of(context).pop();
              _fetchDrivers();
              _showSuccessPopup();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A3636), // พื้นหลังสีเข้มของ Popup
        title: const Text('Add Driver',
            style: TextStyle(color: Colors.white)), // ตัวหนังสือสีขาว
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF40534C), // พื้นหลังของ TextField
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF40534C), // พื้นหลังของ TextField
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await _addDriver(
                  usernameController.text, passwordController.text);
              Navigator.of(context).pop();
              _showSuccessPopup(message: 'Driver added successfully');
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF40534C), // พื้นหลังสีเข้มของ Popup
        title: const Text('Delete Driver',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255))), // ตัวหนังสือสีขาว
        content: const Text('Are you sure you want to delete this driver?',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              await _deleteDriver(driverId);
              Navigator.of(context).pop();
              _fetchDrivers();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFE96464))),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup({String message = 'Rename successfully'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A3636), // พื้นหลังสีเข้มของ Popup
        title: const Text('Success', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (drivers.length / _itemsPerPage).ceil();
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showAddDriverDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3636), // สีปุ่ม Add Driver
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // ขอบปุ่มเหลี่ยม
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12), // ขนาดของปุ่ม
          ),
          child: const Text(
            'Add Driver',
            style: TextStyle(
              color: Colors.white, // สีตัวหนังสือสีขาว
              fontWeight: FontWeight.w600, // ทำให้ตัวหนังสือหนาขึ้นเล็กน้อย
            ),
          ),
        ), // ปุ่ม Add Driver ย้ายมาที่นี่
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            Text('Page ${_currentPage + 1} of $totalPages'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Amount of ${drivers.length} drivers',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
