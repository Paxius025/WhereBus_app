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
  bool _isPasswordVisible = false; // สถานะสำหรับการแสดง/ซ่อนรหัสผ่าน
  String _selectedRole = 'user'; // กำหนดค่าเริ่มต้นเป็น user
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[!-/:-@[-`{-~]).{7,20}$');

  final ApiService apiService = ApiService();

  bool _isLoading = false;
  String _successMessage = '';

  // Popup แสดงข้อความและ Icon สีเขียว
  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green, // ไอคอนถูกสีเขียว
                size: 70,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // ปิด Popup หลังจาก 1.5 วินาทีแล้วไปที่หน้า Login
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cancel,
                  color: Colors.red, // ไอคอน X สีแดง
                  size: 70,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void _register() async {
    setState(() {
      _isLoading = true;
      _successMessage = '';
    });

    // ตรวจสอบ username และ password ว่าอยู่ระหว่าง 1 -15 ตัวอักษรหรือไม่
    if (_usernameController.text.isEmpty) {
      _showErrorDialog('Username can\'t be blank.');
      setState(() {
        _isLoading = false;
      });
      return;
    } else if (_usernameController.text.length < 1 ||
        _usernameController.text.length > 15) {
      _showErrorDialog('Username must be between 1-15 characters long.');
      setState(() {
        _isLoading = false;
      });
      return;
    } else if (_passwordController.text.length < 8 ||
        _passwordController.text.length > 20) {
      _showErrorDialog('Password must be between 8-20 characters long.');
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
        _selectedRole,
      );

      if (response['status'] == 'success') {
        _showSuccessPopup('Registration successful!');
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
                  'assets/register_icon.png',
                  height: 200,
                  width: 200,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Icon(
                      Icons.account_circle,
                      size: 200,
                      color: Colors.grey,
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
                          // เพิ่ม IconButton สำหรับการแสดง/ซ่อนรหัสผ่าน
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText:
                            !_isPasswordVisible, // ควบคุมการแสดงรหัสผ่าน
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
