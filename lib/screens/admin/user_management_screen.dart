// lib/screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 0;
  final int _itemsPerPage = 10; // เปลี่ยนเป็น 10 คนต่อหน้า

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้ทั้งหมด
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Overview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildUserTable(),
                              _buildPaginationControls(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildUserTable() {
    // คำนวณตำแหน่งเริ่มต้นและสิ้นสุดของรายการที่จะนำมาแสดงในหน้าปัจจุบัน
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = (_currentPage + 1) * _itemsPerPage > users.length
        ? users.length
        : (_currentPage + 1) * _itemsPerPage;

    List<Map<String, dynamic>> currentItems =
        users.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
        columns: const [
          DataColumn(
            label: Text(
              'ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'USERNAME',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'DEL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: currentItems
            .map(
              (user) => DataRow(
                cells: [
                  DataCell(Text(user['id'].toString())),
                  DataCell(Text(user['username'])),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          users.remove(user);
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // ฟังก์ชันสำหรับการควบคุมการเปลี่ยนหน้า (Pagination)
  Widget _buildPaginationControls() {
    int totalPages = (users.length / _itemsPerPage).ceil();
    int startIndex = _currentPage * _itemsPerPage + 1;
    int endIndex = (_currentPage + 1) * _itemsPerPage > users.length
        ? users.length
        : (_currentPage + 1) * _itemsPerPage;

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
        SizedBox(height: 10),
        Text(
          'Amount of ${users.length} users',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
