import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_status_screen.dart';
import 'package:wherebus_app/screens/main_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  final int userId;
  final String email; // รับ email จากหน้าอื่น
  final String role; // รับ role จากหน้าอื่น

  const AdminDashboardScreen({
    super.key,
    required this.username,
    required this.userId,
    required this.email,
    required this.role,
  });

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // สีพื้นหลังของ AppBar เป็นสีขาว
        title: const Text(
          'Admin Dashboard', // ชื่อหน้าแสดงเป็น 'Admin Dashboard'
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black, // สีตัวหนังสือสีดำ
          ),
        ),
        centerTitle: true, // จัดข้อความตรงกลาง
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right:
                    15), // เพิ่ม padding ให้ปุ่ม X ห่างจากขอบจอ 15% ของความกว้างหน้าจอ
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: Color(0xFF7F7777)), // ปุ่ม X สีขาว
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(
                      username: widget.username,
                      userId: widget.userId,
                      role: widget.role,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // สีพื้นหลังของหน้าเป็นสีขาว
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .start, // เปลี่ยนจาก center เป็น start เพื่อให้เนื้อหาชิดด้านบน
          crossAxisAlignment:
              CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางในแนวนอน
          children: [
            // ลบ SizedBox เพื่อลดความห่าง
            _buildAdminMenuIcon(
              'assets/users_no_border.png',
              Icons.groups,
            ),
            const SizedBox(height: 15), // ระยะห่างระหว่างไอคอนกับป้าย
            _buildAdminMenuLabel(
              label: 'Manage User',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(
                      username: widget.username,
                      email: widget.email,
                      userId: widget.userId,
                      role: widget.role,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15), // ระยะห่างระหว่างเมนู

            _buildAdminMenuIcon(
              'assets/driver_avatar.png',
              Icons.assignment_ind,
            ),
            const SizedBox(height: 5), // ระยะห่างระหว่างไอคอนกับป้าย
            _buildAdminMenuLabel(
              label: 'Manage Driver',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverManagementScreen(
                      username: widget.username,
                      email: widget.email,
                      userId: widget.userId,
                      role: widget.role,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15), // ระยะห่างระหว่างเมนู

            _buildAdminMenuIcon(
              'assets/bus_avatar.png',
              Icons.directions_bus,
            ),
            const SizedBox(height: 5), // ระยะห่างระหว่างไอคอนกับป้าย
            _buildAdminMenuLabel(
              label: 'Bus Status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStatusScreen(
                      username: widget.username,
                      email: widget.email,
                      userId: widget.userId,
                      role: widget.role,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงไอคอน (ไม่รองรับการกด)
  Widget _buildAdminMenuIcon(String imagePath, IconData fallbackIcon) {
    return CircleAvatar(
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), // พื้นหลังเป็นสีขาว
      radius: 80, // ขนาดวงกลมของไอคอน
      child: _loadImageWithFallback(
          imagePath, fallbackIcon), // โหลดไอคอนหรือรูปภาพ
    );
  }

  // ฟังก์ชันสำหรับแสดงป้ายข้อความที่รองรับการกด
  Widget _buildAdminMenuLabel({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // ทำงานเมื่อกดที่ป้ายข้อความ
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF677D6A), // พื้นหลังของป้ายเป็นสีเขียวเข้ม
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // เงาสีดำอ่อน
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 0.05), // เงาในแนวตั้ง
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6), // ระยะห่างภายในป้าย
        width: 140, // กำหนดความกว้างของป้ายข้อความให้เท่ากัน
        child: Center(
          child: Text(
            label, // แสดงชื่อเมนู
            style: const TextStyle(
              fontSize: 14, // ขนาดตัวหนังสือ
              fontWeight: FontWeight.bold, // น้ำหนักตัวหนังสือหนา
              color: Colors.white, // ตัวหนังสือสีขาว
            ),
            softWrap: false, // ไม่ให้ตัดคำในป้ายข้อความ
            overflow: TextOverflow.ellipsis, // ตัดข้อความถ้ายาวเกิน
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับโหลดรูปภาพพร้อม fallback เป็นไอคอนเมื่อรูปไม่โหลด
  Widget _loadImageWithFallback(String imagePath, IconData fallbackIcon) {
    return Image.asset(
      imagePath, // พาธของรูปภาพ
      height: 130, // ความสูงของรูปภาพ
      width: 130, // ความกว้างของรูปภาพ
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Icon(
          fallbackIcon, // แสดงไอคอนแทนถ้าโหลดรูปภาพไม่สำเร็จ
          size: 130, // ขนาดไอคอน
          color: Colors.grey, // สีของไอคอน
        );
      },
    );
  }
}
