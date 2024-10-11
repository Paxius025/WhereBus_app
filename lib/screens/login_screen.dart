import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/main_screen.dart';
import 'package:wherebus_app/screens/register_screen.dart'; // Import Register Screen
import 'package:stroke_text/stroke_text.dart'; // Import stroke_text เพื่อใช้สร้างกรอบตัวอักษร
import 'package:google_fonts/google_fonts.dart';

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
  bool _isPasswordVisible = false; // ตัวแปรสำหรับควบคุมการแสดง/ซ่อนรหัสผ่าน

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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return MainScreen(
                role: role,
                userId: response['user_id'],
                username: _usernameController.text,
              );
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Fade Transition ค่อยๆ แสดงหน้าแมพ
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        String errorMessage = response['message'] == 'Invalid credentials'
            ? 'Incorrect username or password'
            : response['message'] ?? 'Login failed, please try again';

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
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
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.cancel,
                  color: Color.fromARGB(255, 255, 0, 0),
                  size: 70,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
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
                    textStyle: GoogleFonts.lilitaOne(
                      textStyle: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 5,
                  ),
                ),
                const SizedBox(height: 60),
                // ครึ่งล่างเป็นส่วนของการกรอกข้อมูล
                FractionallySizedBox(
                  widthFactor: 0.85,
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible =
                                    !_isPasswordVisible; // สลับสถานะการแสดง/ซ่อนรหัสผ่าน
                              });
                            },
                          ),
                        ),
                        obscureText:
                            !_isPasswordVisible, // ควบคุมการแสดงรหัสผ่าน
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
                          const Text(
                            "Don't have an account?,",
                            style: TextStyle(
                              color: Color(0xFF7F7777),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return const RegisterScreen();
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin =
                                        Offset(-1.0, 0.0); // เริ่มจากซ้ายไปขวา
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: child,
                                    );
                                  },
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
