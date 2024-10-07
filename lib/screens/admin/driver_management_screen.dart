// lib/screens/admin/driver_management_screen.dart
import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';

class DriverManagementScreen extends StatefulWidget {
  @override
  _DriverManagementScreenState createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> drivers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 0;
  final int _itemsPerPage = 10;

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
      appBar: AppBar(
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
                      ElevatedButton(
                        onPressed: () {
                          _showAddDriverDialog();
                        },
                        child: const Text('Add Driver'),
                      ),
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

    // Adjusting column widths to fit in smaller screens (min screen width: 320px)
    double idWidth = screenWidth * 0.10; // 10% of screen width for ID
    double usernameWidth =
        screenWidth * 0.50; // 50% of screen width for USERNAME
    double actionWidth = screenWidth * 0.30; // 30% of screen width for ACTION

    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
      columnSpacing: 10,
      columns: [
        DataColumn(
          label: SizedBox(
            width: idWidth < 30 ? 30 : idWidth, // Minimum width for ID column.
            child: const Text(
              'ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: usernameWidth < 100
                ? 100
                : usernameWidth, // Minimum width for USERNAME column.
            child: const Text(
              'USERNAME',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: actionWidth < 80
                ? 80
                : actionWidth, // Minimum width for ACTION column.
            child: const Text(
              'ACTION',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
      rows: currentItems
          .map(
            (driver) => DataRow(
              cells: [
                DataCell(Text(driver['id'].toString(),
                    style: const TextStyle(fontSize: 12))),
                DataCell(Text(driver['username'],
                    style: const TextStyle(fontSize: 12))),
                DataCell(
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the action icons
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 20,
                        ),
                        onPressed: () {
                          _showRenameDialog(driver['id'], driver['username']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          _showDeleteConfirmation(driver['id']);
                        },
                      ),
                    ],
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
        title: Text('Rename Driver'),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(labelText: 'New Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await apiService.updateDriver(
                  driverId, usernameController.text, '');
              Navigator.of(context).pop();
              _fetchDrivers();
              _showSuccessPopup();
            },
            child: Text('Save'),
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
        title: Text('Add Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _addDriver(
                  usernameController.text, passwordController.text);
              Navigator.of(context).pop();
              _showSuccessPopup(message: 'Driver added successfully');
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Driver'),
        content: Text('Are you sure you want to delete this driver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteDriver(driverId);
              Navigator.of(context).pop();
              _fetchDrivers();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup({String message = 'Rename successfully'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (drivers.length / _itemsPerPage).ceil();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
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
              icon: Icon(Icons.arrow_forward),
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
        const SizedBox(height: 10),
        Text(
          'Amount of ${drivers.length} drivers',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
