import 'package:flutter/material.dart';

class OtpSuccessScreen extends StatelessWidget {
  const OtpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.15),
                border: Border.all(
                  color: Colors.greenAccent.shade200,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.greenAccent.shade200,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Phone Verified!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your phone number has been verified successfully.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
