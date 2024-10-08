import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_status_screen.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart'; // Import Navigation Bar

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  final int userId;
  final String email; // เพิ่ม email ที่รับจากหน้าอื่น
  final String role; // เพิ่ม role ที่รับจากหน้าอื่น

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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // สีพื้นหลังของ AppBar สีขาว
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black, // ตัวหนังสือสีดำ
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // ปุ่มย้อนกลับสีดำ
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Transform.scale(
            scale: 0.85, // ลดขนาดหน้าจอ 15%
            child: FractionallySizedBox(
              widthFactor: screenWidth < 600 ? 0.9 : 0.6, // Responsive width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5), // เว้นช่องว่างด้านบน
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/users.png', // path ของรูป
                      Icons.groups, // icon แทนถ้ารูปไม่โหลด
                    ),
                    label: 'User Management',
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
                  const SizedBox(height: 20),
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/driver_avatar.png', // path ของรูป
                      Icons.assignment_ind, // icon แทนถ้ารูปไม่โหลด
                    ),
                    label: 'Driver Management',
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
                  const SizedBox(height: 20),
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/bus_avatar.png', // path ของรูป
                      Icons.directions_bus, // icon แทนถ้ารูปไม่โหลด
                    ),
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
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        role: widget.role,
      ), // เพิ่ม Navigation Bar ที่ด้านล่าง
    );
  }

  Widget _buildAdminMenuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            radius: 60,
            child: icon,
          ),
          const SizedBox(height: 10),
          Container(
            color: const Color(0xFF677D6A), // สีพื้นหลัง #677D6A สำหรับเมนู
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            width: 180, // กำหนดขนาดความกว้างของ label ให้เท่ากัน
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14, // ลดขนาดตัวหนังสือเพื่อให้อยู่ในบรรทัดเดียว
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ตัวหนังสือสีขาว
                ),
                softWrap: false, // ไม่ให้ตัดคำข้ามบรรทัด
                overflow: TextOverflow.ellipsis, // ตัดข้อความถ้ายาวเกิน
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับโหลดรูปภาพพร้อม fallback ถ้ารูปไม่สามารถโหลดได้
  Widget _loadImageWithFallback(String imagePath, IconData fallbackIcon) {
    return Image.asset(
      imagePath,
      height: 120, // ขนาดความสูงของรูป
      width: 120, // ขนาดความกว้างของรูป
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Icon(
          fallbackIcon,
          size: 100, // ขนาดของไอคอนที่แสดงแทน
          color: Colors.grey, // สีของไอคอน
        );
      },
    );
  }
}
