import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/main_screen.dart';
import 'package:wherebus_app/screens/register_screen.dart'; // Import Register Screen
import 'package:stroke_text/stroke_text.dart'; // Import stroke_text เพื่อใช้สร้างกรอบตัวอักษร

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (response['status'] == 'success') {
        String role = response['role'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              role: role,
              userId: response['user_id'],
              username: _usernameController.text,
            ),
          ),
        );
      } else {
        // เปลี่ยนข้อความ "Invalid credential" เป็นข้อความที่คุณต้องการแสดง
        String errorMessage = response['message'] == 'Invalid credentials'
            ? 'Incorrect username or password'
            : response['message'] ?? 'Login failed, please try again';

        // แสดงป๊อปอัปเมื่อ login ไม่ผ่าน
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // แสดงป๊อปอัปเมื่อเกิดข้อผิดพลาด
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                    fontSize: 12,
                  ), // ข้อความสีแดง
                  textAlign: TextAlign.center, // จัดข้อความให้อยู่กลาง
                ),
              ],
            ),
          ),
        );
      },
    );

    // ปิดป๊อปอัปอัตโนมัติหลังจาก 1 วินาที
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // ปิดป๊อปอัป
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ครึ่งบนแสดง WhereBus
                Center(
                  child: StrokeText(
                    text: 'WhereBus',
                    textStyle: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 7,
                  ),
                ),
                const SizedBox(height: 70),
                // ครึ่งล่างเป็นส่วนของการกรอกข้อมูล
                FractionallySizedBox(
                  widthFactor: 0.85, // ให้ช่องกรอกอยู่ตรงกลาง 85% ของหน้าจอ
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1A3636),
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF7F7777).withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1A3636),
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF7F7777).withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3636),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 10),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text('LOGIN'),
                            ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ,",
                            style: const TextStyle(
                              color: Color(0xFF7F7777),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              " Register here",
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
