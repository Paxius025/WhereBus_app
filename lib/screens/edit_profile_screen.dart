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
  }); // รับ role มาใน constructor

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
        await Future.delayed(Duration(milliseconds: 500));

        // แสดงข้อความสำเร็จใน pop-up
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
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
      backgroundColor: Color(0xFF1A3636), // สีพื้นหลังของหน้าเป็นสี #1A3636
      appBar: AppBar(
        backgroundColor: Color(0xFF1A3636),
        automaticallyImplyLeading: false,
        title: Text('EDIT PROFILE'),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: AssetImage(
                            widget.role == 'admin'
                                ? 'admin.png' // รูปภาพของ admin
                                : widget.role == 'driver'
                                    ? 'driver_avatar.png' // รูปภาพของ driver
                                    : 'user_avatar.png', // รูปภาพของ user ทั่วไป
                          ),
                          fit: BoxFit.cover,
                        ),
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
                            style: TextStyle(color: Color(0xFF7F7777)),
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Color(0xFF7F7777)),
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
                            style: TextStyle(color: Color(0xFF7F7777)),
                            decoration: InputDecoration(
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(color: Color(0xFF7F7777)),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110, // กำหนดความกว้างของปุ่ม SAVE
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF40534C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: const Text('SAVE'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 110, // กำหนดความกว้างของปุ่ม CANCEL
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF7F7777),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: const Text('CANCEL'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_successMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _successMessage,
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    const SizedBox(height: 50),
                    const Text(
                      'WhereBus Version 1.0.1\nPantong | Jedsada | Tharathep | Apirak',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE96464),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        minimumSize: Size(45, 35),
                      ),
                      child: Text('LOGOUT'),
                    ),
                  ],
                ),
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
}
