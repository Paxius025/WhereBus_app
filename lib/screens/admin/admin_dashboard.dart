import 'package:flutter/material.dart';
import 'user_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_status_screen.dart';
import 'package:wherebus_app/widgets/navigation_bar.dart'; // Import Navigation Bar สำหรับ Navigation ด้านล่าง

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
    double screenWidth = MediaQuery.of(context)
        .size
        .width; // รับความกว้างของหน้าจอสำหรับการจัดตำแหน่ง responsive

    return Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // ปุ่มย้อนกลับและไอคอนสีดำ
          onPressed: () {
            Navigator.pop(
                context); // เมื่อกดปุ่มย้อนกลับจะกลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // สีพื้นหลังของหน้าเป็นสีขาว
      body: Center(
        child: SingleChildScrollView(
          // ใช้ SingleChildScrollView เพื่อให้หน้าจอสามารถเลื่อนลงได้ในกรณีที่หน้าจอขนาดเล็ก
          child: Transform.scale(
            scale: 0.85, // ลดขนาดหน้าจอลง 15%
            child: FractionallySizedBox(
              widthFactor: screenWidth < 600
                  ? 0.9
                  : 0.6, // จัดการให้การแสดงผล responsive (หน้าจอเล็กใช้ 90% ของความกว้าง, ใหญ่ใช้ 60%)
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดให้อยู่ตรงกลางตามแนวตั้ง
                crossAxisAlignment:
                    CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางตามแนวนอน
                children: [
                  const SizedBox(height: 0), // ไม่มีระยะห่างด้านบน
                  // เมนู User Management
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/users.png', // ใช้รูปจาก assets
                      Icons.groups, // หากโหลดรูปไม่สำเร็จให้แสดงไอคอนกลุ่มแทน
                    ),
                    label: 'User Management', // ป้ายชื่อเมนู 'User Management'
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
                  const SizedBox(height: 10), // ระยะห่าง 10px
                  // เมนู Driver Management
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/driver_avatar.png', // ใช้รูปจาก assets
                      Icons
                          .assignment_ind, // หากโหลดรูปไม่สำเร็จให้แสดงไอคอนบุคคลแทน
                    ),
                    label:
                        'Driver Management', // ป้ายชื่อเมนู 'Driver Management'
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
                  const SizedBox(height: 10), // ระยะห่าง 10px
                  // เมนู Bus Status
                  _buildAdminMenuItem(
                    icon: _loadImageWithFallback(
                      'assets/bus_avatar.png', // ใช้รูปจาก assets
                      Icons
                          .directions_bus, // หากโหลดรูปไม่สำเร็จให้แสดงไอคอนรถบัสแทน
                    ),
                    label: 'Bus Status', // ป้ายชื่อเมนู 'Bus Status'
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
      // Navigation Bar ด้านล่าง
      bottomNavigationBar: NavigationBarWidget(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        role: widget.role, // ส่งค่า role ให้ Navigation Bar
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างเมนู Admin โดยรับค่าไอคอน, ชื่อเมนู และฟังก์ชัน onTap เมื่อกดเมนู
  Widget _buildAdminMenuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      // ใช้ GestureDetector เพื่อให้เมนูสามารถคลิกได้
      onTap: onTap, // เมื่อคลิกจะทำงานตามฟังก์ชันที่กำหนดใน onTap
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // จัดให้ไอคอนและข้อความอยู่ตรงกลาง
        children: [
          CircleAvatar(
            backgroundColor:
                const Color.fromARGB(255, 255, 255, 255), // พื้นหลังเป็นสีขาว
            radius: 60, // ขนาดวงกลมของไอคอน
            child: icon, // แสดงไอคอนหรือรูปภาพ
          ),
          const SizedBox(height: 10), // ระยะห่างระหว่างไอคอนและป้ายชื่อ
          Container(
            color:
                const Color(0xFF677D6A), // พื้นหลังของป้ายชื่อเป็นสีเขียวเข้ม
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 10), // ระยะห่างภายในป้าย
            width: 180, // ความกว้างของป้ายชื่อ
            child: Center(
              child: Text(
                label, // แสดงชื่อเมนู
                style: const TextStyle(
                  fontSize: 14, // ขนาดตัวหนังสือ
                  fontWeight: FontWeight.bold, // น้ำหนักตัวหนังสือหนา
                  color: Colors.white, // ตัวหนังสือสีขาว
                ),
                softWrap: false, // ไม่ให้ตัดคำในป้ายชื่อ
                overflow:
                    TextOverflow.ellipsis, // ตัดข้อความถ้าชื่อเมนูยาวเกินไป
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับโหลดรูปภาพพร้อม fallback เป็นไอคอนเมื่อรูปไม่โหลด
  Widget _loadImageWithFallback(String imagePath, IconData fallbackIcon) {
    return Image.asset(
      imagePath, // พาธของรูปภาพ
      height: 120, // ความสูงของรูปภาพ
      width: 120, // ความกว้างของรูปภาพ
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Icon(
          fallbackIcon, // แสดงไอคอนแทนถ้าโหลดรูปภาพไม่สำเร็จ
          size: 100, // ขนาดไอคอน
          color: Colors.grey, // สีของไอคอน
        );
      },
    );
  }
}
