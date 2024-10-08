import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String role;

  const UserManagementScreen({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
    required this.role,
  });

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 0;
  final int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await apiService.getUsers();
      if (response['status'] == 'success') {
        setState(() {
          users = List<Map<String, dynamic>>.from(response['users']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final response = await apiService.deleteUser(userId);
      if (response['status'] == 'success') {
        setState(() {
          users.removeWhere((user) => user['id'] == userId);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to delete user';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting user: $e';
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(int userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                4.0), // Almost square corners for the dialog
          ),
          backgroundColor: const Color(0xFFFFFFFF), // Background color FFFFFF
          title: const Text(
            'Delete User',
            style: TextStyle(color: Colors.black), // Title color
          ),
          content: const Text(
            'Are you sure you want to delete this user?',
            style: TextStyle(color: Colors.black), // Content text color
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFFFFFF), // Background color FFFFFF
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Almost square corners for the button
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF7F7777), // Text color 7F7777F
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE96464), // Background color E96464
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Almost square corners for the button
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFFFFFF), // Text color FFFFFF
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteUser(userId); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), // พื้นหลังสีขาว
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // พื้นหลังสีขาว
        title: const Text('User Overview',
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0))), // ตัวหนังสือสีดำ
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // ลบขอบออก
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10), // ย่อขนาดให้เล็กลงเล็กน้อย
                      Expanded(
                        child: _buildUserTable(), // ตารางแสดงข้อมูล
                      ),
                      _buildPaginationControls(), // ควบคุมการเปลี่ยนหน้า
                    ],
                  ),
      ),
    );
  }

  Widget _buildUserTable() {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = (_currentPage + 1) * _itemsPerPage > users.length
        ? users.length
        : (_currentPage + 1) * _itemsPerPage;

    List<Map<String, dynamic>> currentItems =
        users.sublist(startIndex, endIndex);

    return ListView(
      shrinkWrap: true, // จำกัดขนาดตามข้อมูล
      children: [
        DataTable(
          headingRowColor: MaterialStateProperty.all(
              const Color(0xFF40534C)), // พื้นหลังสีเขียวของหัวตาราง
          columns: const [
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // ตัวหนังสือสีขาว
              ),
            ),
            DataColumn(
              label: Text(
                'USERNAME',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // ตัวหนังสือสีขาว
              ),
            ),
            DataColumn(
              label: Text(
                'DELETE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // ตัวหนังสือสีขาว
              ),
            ),
          ],
          rows: currentItems
              .map(
                (user) => DataRow(
                  color: MaterialStateProperty.all(
                      Colors.white), // พื้นหลังของข้อมูลแถวเป็นสีขาว
                  cells: [
                    DataCell(Text(
                      user['id'].toString(),
                      style: const TextStyle(
                          color: Color(0xFF7F7777)), // ตัวหนังสือสีเทา
                    )),
                    DataCell(Text(
                      user['username'],
                      style: const TextStyle(
                          color: Color(0xFF7F7777)), // ตัวหนังสือสีเทา
                    )),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _showDeleteConfirmationDialog(user['id']);
                        },
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (users.length / _itemsPerPage).ceil();
    return Column(
      children: [
        const SizedBox(height: 10), // ปรับระยะห่างให้เลื่อนขึ้น 20px
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
        const SizedBox(height: 10), // ยกข้อความแสดงจำนวนขึ้น 20px
        Text(
          'Amount of ${users.length} users',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
