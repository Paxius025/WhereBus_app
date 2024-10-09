# 🚌 WhereBus

**WhereBus** เป็นแอปพลิเคชันที่ช่วยให้ผู้ใช้สามารถติดตามตำแหน่งของรถบัสได้แบบเรียลไทม์ 📍 โดยแอปนี้ถูกพัฒนาด้วย **Flutter** สำหรับฝั่งผู้ใช้ และ **PHP** สำหรับฝั่งเซิร์ฟเวอร์ พร้อมกับการใช้ **MySQL** สำหรับการจัดการฐานข้อมูล

## Introduction
WhereBus ช่วยให้ผู้ใช้งานสามารถติดตามตำแหน่งของรถบัสได้ โดยผู้ใช้งานสามารถเห็นตำแหน่งปัจจุบันของรถบัสที่กำลังวิ่งอยู่ 

## 📖 Project Details
WhereBus เป็นการพัฒนาด้วยการนำการส่งตำแหน่ง **GPS** จากอุปกรณ์ **ESP32** ซึ่งทำหน้าที่รับสัญญาณ GPS และส่งข้อมูลไปยังเซิร์ฟเวอร์ผ่านเครือข่ายแบบเรียลไทม์ ทำให้ผู้ใช้สามารถดูตำแหน่งรถบัสบนแผนที่ในแอปได้ทันที

## 🌟 Features
- **ติดตามรถบัส**: ผู้ใช้สามารถดูตำแหน่งปัจจุบันของรถบัสบนแผนที่
- **ระบบผู้ใช้**: รองรับการสมัครสมาชิก การเข้าสู่ระบบ และการจัดการโปรไฟล์
- **ระบบผู้ดูแลระบบ**: ผู้ดูแลสามารถจัดการผู้ใช้ คนขับรถ และดูข้อมูลรถบัส
- **ระบบคนขับรถ**: คนขับสามารถอัปเดตตำแหน่งของตัวเองและดูจำนวนผู้โดยสารในขณะนั้น

## 🛠️ Tech Stack
- **Front-end**: Flutter
- **Back-end**: PHP
- **Database**: MySQL

## 🗄️ Data Storage
โครงสร้างฐานข้อมูลถูกออกแบบด้วย **MySQL** โดยมีตารางหลักดังนี้:
- **users**: เก็บข้อมูลผู้ใช้ เช่น id, username, password, email, role
- **drivers**: เก็บข้อมูลคนขับรถ
- **buses**: เก็บข้อมูลรถบัส เช่น หมายเลขรถ สถานะ
- **locations**: เก็บข้อมูลตำแหน่งของรถบัส (latitude, longitude, timestamp)

## Installation
1. **ติดตั้ง Flutter SDK**:
   - ดาวน์โหลดและติดตั้งจาก [Flutter SDK](https://flutter.dev/docs/get-started/install)
   - คลอนโปรเจกต์ Flutter โดยใช้คำสั่ง:
     ```bash
     git clone <URL>
     cd wherebus-client
     flutter pub get
     flutter run
     ```

2. **ติดตั้งเซิร์ฟเวอร์ PHP และ MySQL**:
   - ติดตั้ง PHP 7+ และ MySQL
   - ตั้งค่าฐานข้อมูลตามที่โปรเจกต์กำหนด

## Usage
- เปิดแอป WhereBus บนมือถือของคุณเพื่อดูตำแหน่งของรถบัสที่ใกล้เคียง
- ดูข้อมูลได้ทั้งในรูปแบบแผนที่

## 📦 Dependencies
### Client-side (Flutter)
- Flutter SDK
- HTTP Package
- Geolocator Plugin
- latlong2
- Cupertino Icons
- flutter_map
- flutter_launcher_icons

### Server-side (PHP)
- PHP 7+
- MySQL
- PHPMyAdmin (optional)

## Troubleshooting
- **ปัญหาในการแสดงตำแหน่งรถบัส**: ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต และอนุญาตการเข้าถึงตำแหน่ง
- **การเชื่อมต่อกับเซิร์ฟเวอร์ล้มเหลว**: ตรวจสอบการตั้งค่าฐานข้อมูลและไฟล์ `.env`

## 🤝 Contributors
- **Pantong** 🧑‍💻
- **Jedsada** 👨‍💻
- **Tharathep** 👨‍💻
- **Apirak** 🧑‍💻

## 📄 License
This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 📞 Contact
หากมีข้อสงสัยหรือปัญหาใด ๆ สามารถติดต่อได้ที่:
- **Email**: pantong.s@ku.th
