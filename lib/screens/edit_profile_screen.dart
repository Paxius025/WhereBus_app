import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/main_screen.dart'; // Import MainScreen เพื่อกลับไปหลังอัปเดต
import 'package:wherebus_app/screens/login_screen.dart'; // Import LoginScreen เพื่อใช้สำหรับ logout
import 'package:wherebus_app/widgets/navigation_bar.dart'; // Import Navigation Bar

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String role; // เพิ่ม role เพื่อเก็บสถานะ

  EditProfileScreen({
    required this.username,
    required this.email,
    required this.userId,
    required this.role,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _emailController.text = widget.email;
  }

  // ฟังก์ชันสำหรับอัปเดตโปรไฟล์
  void _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await apiService.updateProfile(
        widget.userId,
        _usernameController.text,
        _emailController.text,
        _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (response['status'] == 'success') {
        setState(() {
          _successMessage = 'Profile updated successfully';
        });

        // หน่วงเวลา 0.5 วินาทีก่อนแสดง pop-up การบันทึกสำเร็จ
        await Future.delayed(const Duration(milliseconds: 500));

        // แสดงข้อความสำเร็จใน pop-up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // นำผู้ใช้กลับไปที่ MainScreen พร้อมส่งข้อมูลล่าสุดกลับไป และคง role เดิม
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              role: widget.role,
              username: _usernameController.text,
              userId: widget.userId,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Update failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันสำหรับ Logout
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF1A3636), // สีพื้นหลังของหน้าเป็นสี #1A3636
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3636),
        title: const Text('EDIT PROFILE'),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ใช้ Spacer เพื่อจัดการระยะห่างให้สมดุลในแนวตั้ง
                  Spacer(flex: 2), // ด้านบน
                  Transform.scale(
                    scale: 0.90, // ลดขนาดหน้าจอทั้งหมดลง 10%
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: ClipOval(
                            child: _loadImageWithFallback(
                                widget.role), // โหลดรูปพร้อม fallback
                          ),
                        ),
                        const SizedBox(height: 40),
                        FractionallySizedBox(
                          widthFactor:
                              0.7, // บีบให้ช่องข้อความกว้างเพียง 70% ของหน้าจอ
                          child: Column(
                            children: [
                              TextField(
                                controller: _usernameController,
                                style:
                                    const TextStyle(color: Color(0xFF7F7777)),
                                decoration: InputDecoration(
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF7F7777)),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                style: const TextStyle(
                                  color: Color(0xFF7F7777),
                                  fontSize: 11, // ลดขนาดตัวหนังสือเหลือ 11px
                                ),
                                decoration: InputDecoration(
                                  labelText: 'PASSWORD',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF7F7777),
                                    fontSize: 11, // ลดขนาดตัวหนังสือลง 5px
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                obscureText: true, // ซ่อนรหัสผ่าน
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 97, // กำหนดความกว้างของปุ่ม SAVE
                              child: ElevatedButton(
                                onPressed: _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF40534C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: const Text(
                                  'SAVE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 95, // กำหนดความกว้างของปุ่ม CANCEL
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF7F7777),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_successMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _successMessage,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        const SizedBox(height: 15),
                        const Text(
                          'WhereBus Version 1.0.1\nPantong | Jedsada | Tharathep | Apirak',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE96464),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            minimumSize: const Size(45, 35),
                          ),
                          child: const Text('LOGOUT'),
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: 3), // ด้านล่าง
                ],
              ),
            ),
      bottomNavigationBar: NavigationBarWidget(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        role: widget.role,
      ),
    );
  }

  // ฟังก์ชันสำหรับโหลดรูปพร้อม fallback เป็นไอคอน
  Widget _loadImageWithFallback(String role) {
    return Image.asset(
      role == 'admin'
          ? 'assets/admin.png'
          : role == 'driver'
              ? 'assets/driver.png'
              : 'assets/user_avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          role == 'admin'
              ? Icons.engineering
              : role == 'driver'
                  ? Icons.contacts
                  : Icons.account_circle,
          size: 100,
          color: Colors.grey,
        );
      },
    );
  }
}
