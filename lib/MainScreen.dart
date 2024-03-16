import 'package:flutter/material.dart';
import 'package:kyc_app/LogInScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variables for language selection and corresponding text values
  String _selectedLanguage = 'English';

  // Text values for English, Hindi, and Tamil
  late String _kycTitle;
  late String _kycDescription;
  late String _createAccountButtonText;

  @override
  void initState() {
    super.initState();
    _updateText(); // Initialize text values
  }

  // Function to update text based on the selected language
  void _updateText() {
    setState(() {
      if (_selectedLanguage == 'English') {
        _kycTitle = 'KYC, a few clicks away';
        _kycDescription = 'Complete your KYC in minutes';
        _createAccountButtonText = 'Create Account';
      } else if (_selectedLanguage == 'Hindi') {
        _kycTitle = 'केवाईसी, कुछ क्लिक दूर';
        _kycDescription = 'मिनटों में अपना केवाईसी पूरा करें';
        _createAccountButtonText = 'खाता बनाएं';
      } else if (_selectedLanguage == 'Tamil') {
        _kycTitle = 'கைவரி, சில கிளிக்குகள் வெற்றிகரமாக';
        _kycDescription = 'நிமிடங்களில் உங்கள் கைவரியை முடிக்கவும்';
        _createAccountButtonText = 'கணக்கை உருவாக்கவும்';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Hide the app bar
        child: Container(),
      ),
      backgroundColor: Color.fromRGBO(0, 6, 27, 1),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                      _updateText(); // Update text when language changes
                    });
                  }
                },
                items: <String>['English', 'Hindi', 'Tamil']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.green), // Green text color
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Image.asset(
                  'assets/images/getstarted.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kycTitle,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _kycDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color.fromRGBO(97, 115, 149, 1),
                      ),
                      child: Text(
                        _createAccountButtonText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
