import 'package:flutter/material.dart';
import 'package:wherebus_app/services/api_service.dart';
import 'package:wherebus_app/screens/main_screen.dart'; // Import MainScreen เพื่อกลับไปหลังอัปเดต
import 'package:wherebus_app/screens/login_screen.dart'; // Import LoginScreen เพื่อใช้สำหรับ logout

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;

  EditProfileScreen(
      {required this.username, required this.email, required this.userId});

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

        // หน่วงเวลา 1 วินาทีก่อนกลับไปหน้า MainScreen
        await Future.delayed(Duration(seconds: 1));

        // ถ้าอัปเดตสำเร็จ นำผู้ใช้กลับไปที่ MainScreen พร้อมส่งข้อมูลล่าสุดกลับไป
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              role: 'user', // สามารถแก้ไขได้ตาม role ของผู้ใช้
              username: _usernameController.text, // อัปเดต username
              userId: widget.userId, // userId เดิม
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
    // ล้างข้อมูล session หรือ token ที่นี่ถ้ามี (อาจเพิ่มการจัดการ token)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // นำผู้ใช้กลับไปหน้า Login
      (Route<dynamic> route) => false, // ล้าง Stack ทั้งหมดเพื่อไม่ให้กลับมาได้
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Password (leave blank to keep current)'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Update Profile'),
                  ),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout, // ปุ่ม Logout
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
