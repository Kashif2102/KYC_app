import 'package:flutter/material.dart';

class KYCVerifiedScreen extends StatelessWidget {
  const KYCVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 6, 27, 1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // This centers the column vertically
          children: [
            // Placeholder for PNG image, replace with your actual image widget
            Image.asset(
              'assets/images/mark.png', // Replace with your image path
              width: 100, // Adjust the size according to your needs
              height: 100, // Adjust the size according to your needs
            ),
            const SizedBox(height: 20), // Gap between image and text
            const Text(
              'KYC completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Gap between texts
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 32.0), // Adjust the padding as needed
              child: Text(
                "Thanks for submitting your document we'll verify it and complete your KYC as soon as possible",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30), // Gap before the button
          ],
        ),
      ),
    );
  }
}
