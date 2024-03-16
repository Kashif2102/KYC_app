import 'dart:async';
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:kyc_app/Form_and_Database/Form.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage; // Field to hold the passed language value

  const LoginScreen({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final EmailOTP myAuth = EmailOTP();
  bool _isButtonDisabled = false;
  late String _selectedLanguage; // Declare the variable

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        widget.selectedLanguage; // Initialize with the passed language
  }

  @override
  Widget build(BuildContext context) {
    // Text elements based on selected language
    String loginText;
    String emailHintText;
    String getOtpButtonText;
    String otpHintText;
    String verifyOtpButtonText;

    switch (_selectedLanguage) {
      case 'Hindi':
        loginText = 'लॉगिन';
        emailHintText = 'ईमेल पता';
        getOtpButtonText = 'ओटीपी प्राप्त करें';
        otpHintText = 'ओटीपी';
        verifyOtpButtonText = 'ओटीपी सत्यापित करें';
        break;
      case 'Tamil':
        loginText = 'உள்நுழைவு';
        emailHintText = 'மின்னஞ்சல் முகவரி';
        getOtpButtonText = 'ஓடிபி பெறுக';
        otpHintText = 'ஓடிபி';
        verifyOtpButtonText = 'ஓடிபி சரிபார்க்கவும்';
        break;
      default: // English and any other languages will default to English
        loginText = 'Login';
        emailHintText = 'Email Address';
        getOtpButtonText = 'Get OTP';
        otpHintText = 'OTP';
        verifyOtpButtonText = 'Verify OTP';
        break;
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 6, 27, 1),
      body: Column(
        children: [
          Container(
            color: Color.fromRGBO(0, 6, 27, 1),
            child: Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 10),
              child: Image.asset(
                'assets/images/sc.png',
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        loginText,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      SizedBox(height: 50),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: emailHintText,
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isButtonDisabled ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(97, 115, 149, 1),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(getOtpButtonText),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: otpHintText,
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(97, 115, 149, 1),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(verifyOtpButtonText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOTP() async {
    // Disable the button
    setState(() {
      _isButtonDisabled = true;
    });

    // Dynamically set the EmailOTP configuration with the user's email
    myAuth.setConfig(
      appEmail: "me@rohitchouhan.com",
      appName: "Standard Chartered KYC",
      userEmail: _emailController.text.trim(), // Use trimmed email
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    try {
      final success = await myAuth.sendOTP();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("OTP has been sent to your email"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to send OTP. Please try again"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending OTP: $e"),
      ));
    }

    // Enable the button after 15 seconds
    Timer(Duration(seconds: 15), () {
      setState(() {
        _isButtonDisabled = false;
      });
    });
  }

  Future<void> _verifyOTP() async {
    try {
      final isVerified = await myAuth.verifyOTP(
          otp: _otpController.text.trim()); // Direct string comparison
      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("OTP verified successfully!"),
        ));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FormScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid OTP. Please try again"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error verifying OTP: $e"),
      ));
    }
  }
}
