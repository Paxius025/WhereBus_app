import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
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
  bool _isPasswordVisible = false; // ตัวแปรควบคุมการแสดง/ซ่อนรหัสผ่าน

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

    // ตรวจสอบความยาวของชื่อผู้ใช้
    if (_usernameController.text.length < 5) {
      _showUsernameTooShortDialog();
      setState(() {
        _isLoading = false; // ปิดการโหลด
      });
      return;
    }

    // ตรวจสอบว่ามีการกรอกข้อมูลใหม่หรือไม่
    if (_usernameController.text == widget.username &&
        _emailController.text == widget.email &&
        _passwordController.text.isEmpty) {
      _showNoUpdateDialog();
      setState(() {
        _isLoading = false; // ปิดการโหลด
      });
      return;
    }

    try {
      final response = await apiService.updateProfile(
        widget.userId,
        _usernameController.text,
        _emailController.text,
        _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (response['status'] == 'success') {
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

  // ฟังก์ชันสำหรับแสดง popup เมื่อชื่อผู้ใช้สั้นเกินไป
  void _showUsernameTooShortDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Username too short',
                  style: TextStyle(
                    fontSize: 12,
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // ฟังก์ชันสำหรับแสดง popup เมื่ออัปเดตสำเร็จ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Profile updated successfully',
                  style: TextStyle(
                    fontSize: 12,
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // ฟังก์ชันสำหรับแสดง popup ว่าไม่มีการอัปเดตข้อมูล
  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No changes to update',
                  style: TextStyle(
                    fontSize: 12,
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
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
      backgroundColor: const Color(0xFF1A3636),
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
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                    Transform.scale(
                      scale: 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            child: ClipOval(
                              child: _loadImageWithFallback(widget.role),
                            ),
                          ),
                          const SizedBox(height: 35),
                          FractionallySizedBox(
                            widthFactor: 0.75,
                            child: Column(
                              children: [
                                TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(
                                    color: Color(0xFF7F7777),
                                    fontSize: 12,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Username',
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
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF7F7777),
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: !_isPasswordVisible,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 100,
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
                                      fontWeight: FontWeight.bold,
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
                              text: 'WhereBus v1.0.8\n',
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                const TextSpan(
                                  text:
                                      'Pantong | Jedsada | Tharathep | Apirak',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
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
                              minimumSize: const Size(55, 40),
                            ),
                            child: const Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(flex: 3),
                  ],
                ),
              ),
            ),
    );
  }
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
        size: 160,
        color: Colors.grey,
      );
    },
  );
}
