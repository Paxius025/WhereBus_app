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

  final ApiService apiService = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  void _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    if (_usernameController.text.length < 5 ||
        _usernameController.text.length > 10) {
      setState(() {
        _errorMessage = 'Username must be between 5 and 10 characters long.';
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text.length < 4 ||
        _passwordController.text.length > 8) {
      setState(() {
        _errorMessage = 'Password must be between 4 and 8 characters long.';
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
        setState(() {
          _errorMessage = response['message'] ?? 'Registration failed';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Enjoy Your Ride!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // เพิ่ม Image widget ตรงนี้
                Image.asset(
                  'register_icon.png', // แก้ไข path ของรูปตามตำแหน่งที่คุณเก็บรูป
                  height: 200, // กำหนดขนาดความสูงของรูปภาพ
                  width: 200, // กำหนดขนาดความกว้างของรูปภาพ
                ),

                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.85,
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 30),
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
