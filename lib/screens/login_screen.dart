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
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed';
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
