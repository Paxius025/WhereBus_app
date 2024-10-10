// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://babydevgang.com/api/';

  // ฟังก์ชันสำหรับล็อกอิน
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${baseUrl}login.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // ฟังก์ชันสำหรับสมัครสมาชิก
  Future<Map<String, dynamic>> register(
      String username, String email, String password, String role) async {
    final url = Uri.parse('${baseUrl}register.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role, // ส่ง role ไปยัง API
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  // ฟังก์ชันสำหรับดึงตำแหน่งล่าสุดของรถบัสหนึ่งคัน
  Future<Map<String, dynamic>> fetchLatestBusLocation() async {
    final url = Uri.parse('${baseUrl}fetch_bus_location.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch bus location');
    }
  }

  // ฟังก์ชันสำหรับอัปเดตข้อมูลผู้ใช้
  Future<Map<String, dynamic>> updateProfile(
      int userId, String username, String email, String? password) async {
    final url = Uri.parse('${baseUrl}update_profile.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'username': username,
        'email': email,
        if (password != null) 'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลโปรไฟล์ผู้ใช้
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final url = Uri.parse('${baseUrl}get_user_profile.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId, // ส่ง userId ไปยัง API
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  // ฟังก์ชันสำหรับส่งตำแหน่งของผู้ใช้
  Future<Map<String, dynamic>> sendUserLocation(
      int userId, double latitude, double longitude) async {
    final url = Uri.parse('${baseUrl}send_user_location.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send location');
    }
  }

  // ฟังก์ชันสำหรับดึงตำแหน่งของผู้ใช้ทั้งหมด (เฉพาะ driver)
  Future<Map<String, dynamic>> fetchUserLocations(String role) async {
    final url = Uri.parse('${baseUrl}fetch_user_location.php?role=$role');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user locations');
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้ทั้งหมด
  Future<Map<String, dynamic>> getUsers() async {
    final url = Uri.parse('${baseUrl}users/get_users.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  // ฟังก์ชันสำหรับลบผู้ใช้
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final url = Uri.parse('${baseUrl}users/delete_user.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete user');
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลคนขับทั้งหมด
  Future<Map<String, dynamic>> getDrivers() async {
    final url = Uri.parse('${baseUrl}drivers/get_drivers.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch drivers');
    }
  }

  // ฟังก์ชันสำหรับเพิ่มข้อมูลคนขับใหม่
  Future<Map<String, dynamic>> addDriver(
      String username, String password) async {
    final url = Uri.parse('${baseUrl}drivers/add_driver.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add driver');
    }
  }

  // ฟังก์ชันสำหรับอัปเดตข้อมูลคนขับ
  Future<Map<String, dynamic>> updateDriver(
      int driverId, String username, String password) async {
    final url = Uri.parse('${baseUrl}drivers/update_driver.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'driverId': driverId,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update driver');
    }
  }

  // ฟังก์ชันสำหรับลบข้อมูลคนขับ
  Future<Map<String, dynamic>> deleteDriver(int driverId) async {
    final url = Uri.parse('${baseUrl}drivers/delete_driver.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'driverId': driverId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete driver');
    }
  }
}
