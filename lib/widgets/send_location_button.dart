import 'package:flutter/material.dart';
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
        ElevatedButton.icon(
          onPressed: widget.isSendingLocation || _isCountdownActive
              ? null
              : _startCountdown, // ปิดการใช้งานปุ่มในระหว่างที่ส่งหรือขณะนับถอยหลัง
          label: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 700), // ความเร็วในการเปลี่ยนแปลง
            child: Container(
              width: 200, // กำหนดความกว้างคงที่เพื่อรักษาตำแหน่ง
              alignment: Alignment.center, // จัดตำแหน่งให้อยู่ตรงกลาง
              child: Text(
                widget.isSendingLocation
                    ? 'Sending...' // ข้อความระหว่างส่ง
                    : _isCountdownActive
                        ? '$_countdown seconds...' // แสดงนับถอยหลัง
                        : 'Send location', // ข้อความเริ่มต้น
                style: const TextStyle(
                    color: Colors.black, fontSize: 16), // สีข้อความและขนาด
                key: ValueKey<int>(
                    _countdown), // ใช้ key เพื่อให้ AnimatedSwitcher รู้ว่าเป็น widget ใหม่
              ),
            ),
          ),
          icon: const Icon(Icons.send, color: Colors.black), // สีไอคอน
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isSendingLocation
                ? Colors.white
                : const Color(0xFF40534C), // สีพื้นหลัง
            foregroundColor: Colors.black, // สี foreground
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (widget.isSendingLocation)
          const SizedBox(height: 8), // เว้นระยะห่างระหว่างปุ่มและข้อความ
        if (widget.isSendingLocation)
          const Text(
            'Please wait while we send your location...', // ข้อความแสดงการรอ
            style: TextStyle(color: Colors.black), // สีข้อความ
          ),
      ],
    );
  }
}
