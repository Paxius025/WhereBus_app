import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // เพิ่มการนำเข้า Geolocator
import 'dart:async';

class SendLocationButton extends StatefulWidget {
  final bool isSendingLocation; // ใช้สำหรับควบคุมสถานะการส่ง
  final VoidCallback onSendLocation; // ฟังก์ชันสำหรับการส่งตำแหน่ง

  const SendLocationButton({
    Key? key,
    required this.isSendingLocation,
    required this.onSendLocation,
  }) : super(key: key);

  @override
  _SendLocationButtonState createState() => _SendLocationButtonState();
}

class _SendLocationButtonState extends State<SendLocationButton> {
  Timer? _countdownTimer; // Timer สำหรับนับถอยหลัง
  int _countdown = 120; // ตั้งค่าตัวนับถอยหลังเริ่มต้นเป็น 120 วินาที
  bool _isCountdownActive = false; // ตัวแปรเพื่อตรวจสอบสถานะการนับถอยหลัง

  void _startCountdown() {
    // ตรวจสอบอนุญาตตำแหน่ง
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // ขออนุญาตจากผู้ใช้
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      // แสดงป๊อปอัปหากผู้ใช้ยังไม่อนุญาต
      _showPermissionDialog();
    } else {
      // หากอนุญาตเรียบร้อย เริ่มนับถอยหลัง
      setState(() {
        _isCountdownActive = true; // เริ่มนับถอยหลัง
        _countdown = 120; // รีเซ็ตการนับถอยหลัง
        widget.onSendLocation(); // เรียกฟังก์ชันส่งตำแหน่ง
      });

      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          setState(() {
            _countdown--; // ลดค่าการนับถอยหลังลง
          });
        } else {
          timer.cancel(); // ยกเลิกการนับถอยหลังเมื่อถึง 0
          setState(() {
            _isCountdownActive = false; // สิ้นสุดการนับถอยหลัง
            _countdown = 120; // รีเซ็ตการนับถอยหลังให้กลับไปที่ 120
          });
        }
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content:
              const Text('Please allow location access to send your location.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดป๊อปอัป
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // ยกเลิก timer เมื่อ widget ถูกทำลาย
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration:
              const Duration(milliseconds: 1500), // ความเร็วในการเปลี่ยนแปลง
          curve: Curves.easeInOut, // รูปแบบการเปลี่ยนแปลง
          width: 200, // ปรับขนาดความกว้างของกล่อง
          padding:
              const EdgeInsets.symmetric(vertical: 8), // ใช้ padding แนวตั้ง
          child: ElevatedButton.icon(
            onPressed: widget.isSendingLocation || _isCountdownActive
                ? null
                : _startCountdown, // ปิดการใช้งานปุ่มในระหว่างที่ส่งหรือขณะนับถอยหลัง
            label: Text(
              widget.isSendingLocation
                  ? 'Sending...' // ข้อความระหว่างส่ง
                  : _isCountdownActive
                      ? '$_countdown seconds...' // แสดงนับถอยหลัง
                      : 'Send location', // ข้อความเริ่มต้น
              style: const TextStyle(
                color: Colors.white, // สีข้อความ
                fontSize: 16, // ขนาดข้อความ
              ),
            ),
            icon: const Icon(Icons.send, color: Colors.white), // สีไอคอน
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSendingLocation
                  ? Colors.grey // สีพื้นหลังเมื่อกำลังส่ง
                  : const Color(0xFF40534C), // สีพื้นหลังเมื่อปกติ
              padding: const EdgeInsets.symmetric(
                  horizontal: 24), // ใช้ padding แนวนอน
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
