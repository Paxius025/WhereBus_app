import 'package:flutter/material.dart';

class SendLocationButton extends StatelessWidget {
  final bool isSendingLocation;
  final VoidCallback onSendLocation;

  const SendLocationButton({
    Key? key,
    required this.isSendingLocation,
    required this.onSendLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isSendingLocation ? null : onSendLocation,
      label: const Icon(Icons.send, color: Color(0xFFFFFFFF)),
      icon: const Text(
        'Send location',
        style: TextStyle(color: Color(0xFFFFFFFF)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF40534C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
