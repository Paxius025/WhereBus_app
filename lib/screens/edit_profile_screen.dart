import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/main_screen.dart'; // Import MainScreen เพื่อกลับไปหลังอัปเดต
import 'package:wherebus_app/screens/login_screen.dart'; // Import LoginScreen เพื่อใช้สำหรับ logout

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
      _isLoading = true; // เริ่มการโหลด
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
          // _successMessage = 'Profile updated successfully';
        });

        // แสดง popup การอัปเดตสำเร็จ
        _showSuccessDialog();
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
        _isLoading = false; // ปิดการโหลดเมื่อทำงานเสร็จ
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด popup เมื่อกดพื้นที่ว่าง
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // พื้นหลังโปร่งใส
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white, // พื้นหลังสีขาว
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50, // ขนาดเครื่องหมายถูก
                ),
                const SizedBox(height: 10),
                const Text(
                  'Updated successfully',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // หน่วงเวลา 1 วินาทีก่อนกลับไปยังหน้า MainScreen
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context); // ปิด popup
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
    });
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
        automaticallyImplyLeading: false,
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
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.10), // เพิ่มให้ห่างจาก AppBar 10%
                  Transform.scale(
                    scale: 0.9, // ขยายขนาดหน้าจอทั้งหมดขึ้น 5%
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200, // เพิ่มขนาดรูปโปรไฟล์ 10%
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape
                                .circle, // ลบ color ออกเพื่อลบพื้นหลังสีเทา
                          ),
                          child: ClipOval(
                            child: _loadImageWithFallback(
                                widget.role), // โหลดรูปพร้อม fallback
                          ),
                        ),
                        const SizedBox(height: 35),
                        FractionallySizedBox(
                          widthFactor:
                              0.75, // บีบให้ช่องข้อความกว้างขึ้นเล็กน้อย
                          child: Column(
                            children: [
                              TextField(
                                controller: _usernameController,
                                style: const TextStyle(
                                  color: Color(0xFF7F7777),
                                  fontSize: 12,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Username', // ใช้ hintText แทน labelText
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7F7777),
                                    fontSize: 12,
                                  ),
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
                                  fontSize: 12,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Password', // ใช้ hintText แทน labelText
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7F7777),
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                obscureText: true, // ซ่อนข้อความเมื่อพิมพ์
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100, // กำหนดความกว้างของปุ่ม SAVE
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
                                    fontSize:
                                        12, // เพิ่มขนาดตัวหนังสือเป็น 14px
                                    fontWeight:
                                        FontWeight.bold, // ทำตัวหนังสือให้หนา
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            SizedBox(
                              width: 100, // กำหนดความกว้างของปุ่ม CANCEL
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
                                    fontSize:
                                        12, // เพิ่มขนาดตัวหนังสือเป็น 14px
                                    fontWeight:
                                        FontWeight.bold, // ทำตัวหนังสือให้หนา
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
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
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text:
                                'WhereBus Version 1.0.8\n', // update file path  in hosting
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.white), // ขนาดตัวอักษร 15
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    'Pantong | Jedsada | Tharathep | Apirak', // ข้อความบรรทัดที่สอง
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white), // ขนาดตัวอักษร 13
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center, // จัดข้อความตรงกลาง
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
                            minimumSize:
                                const Size(55, 40), // ขยายขนาดปุ่มขึ้น 5%
                          ),
                          child: const Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold, // ตัวหนาสำหรับ LOGOUT
                              fontSize: 14, // เพิ่มขนาดตัวหนังสือเป็น 14px
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: 3), // ด้านล่าง
                ],
              ),
            ),
    );
  }

  // ฟังก์ชันสำหรับโหลดรูปพร้อม fallback เป็นไอคอน
  Widget _loadImageWithFallback(String role) {
    return Image.asset(
      role == 'admin'
          ? 'assets/admin.png'
          : role == 'driver'
              ? 'assets/driver_avatar.png'
              : 'assets/user_avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          role == 'admin'
              ? Icons.engineering
              : role == 'driver'
                  ? Icons.contacts
                  : Icons.account_circle,
          size: 160, // เพิ่มขนาดของไอคอนขึ้น 10%
          color: Colors.grey,
        );
      },
    );
  }
}
