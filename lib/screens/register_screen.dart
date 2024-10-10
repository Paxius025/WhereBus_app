import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user'; // กำหนดค่าเริ่มต้นเป็น user
  // Regular expression to check for at least one special character and one uppercase letter
  final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,20}$');
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  String _successMessage = '';

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิดป๊อปอัปด้วยการคลิกนอก
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // มุมโค้ง
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // ให้ความสูงของป๊อปอัปปรับตามเนื้อหา
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.cancel,
                    color: Color.fromARGB(255, 255, 0, 0), // ไอคอน X เป็นสีขาว
                    size: 70, // ขนาดของไอคอน
                  ),
                ),
                const SizedBox(height: 10), // ระยะห่างระหว่างไอคอนและข้อความ
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ), // ข้อความสีแดง
                  textAlign: TextAlign.center, // จัดข้อความให้อยู่กลาง
                ),
              ],
            ),
          ),
        );
      },
    );

    // ปิดป๊อปอัปอัตโนมัติหลังจาก 1.5 วินาที
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // ปิดป๊อปอัป
    });
  }

  void _register() async {
    setState(() {
      _isLoading = true;
      _successMessage = '';
    });

    // ตรวจสอบ username และ password ว่าอยู่ระหว่าง 8-15 ตัวอักษรหรือไม่
    if ((_usernameController.text.length < 8 ||
            _usernameController.text.length > 15) ||
        (_passwordController.text.length < 8 ||
            _passwordController.text.length > 15)) {
      _showErrorDialog('Username and Password \nmust be 8-15 characters long.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // ตรวจสอบว่า password มีตัวอักษรพิเศษและตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัวหรือไม่
    if (!passwordRegex.hasMatch(_passwordController.text)) {
      _showErrorDialog(
          'Password must include 1 special character \n1 uppercase letter.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await apiService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRole, // ส่ง role ที่เลือกจาก dropdown
      );

      if (response['status'] == 'success') {
        setState(() {
          _successMessage = 'Registration successful! Please login.';
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } else {
        _showErrorDialog(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 0),
                const Text(
                  'Enjoy Your Ride!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // เพิ่ม Image widget ตรงนี้
                Image.asset(
                  'assets/register_icon.png', // แก้ไข path ของรูปตามตำแหน่งที่คุณเก็บรูป
                  height: 200, // กำหนดขนาดความสูงของรูปภาพ
                  width: 200, // กำหนดขนาดความกว้างของรูปภาพ
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    // แสดงไอคอนเมื่อรูปภาพไม่โหลด
                    return Icon(
                      Icons.account_circle, // เปลี่ยนไอคอนที่จะแสดง
                      size: 200, // ขนาดของไอคอนที่จะแสดงแทนรูป
                      color: Colors.grey, // สีของไอคอนที่จะแสดงแทนรูป
                    );
                  },
                ),
                const SizedBox(height: 5),
                FractionallySizedBox(
                  widthFactor: 0.90,
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Color(0xFF7F7777)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Color(0xFF7F7777)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Color(0xFF7F7777)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3636),
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 15),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              child: const Text('Register'),
                            ),
                      if (_successMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _successMessage,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Color(0xFF7F7777)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login now!',
                              style: TextStyle(
                                color: Color(0xFF1A3636),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
