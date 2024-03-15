import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kyc_app/VideoScreen.dart'; // Assuming this is your navigation target

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  PageController _pageController = PageController();
  TextEditingController _aadhaarNumberController = TextEditingController();
  TextEditingController _panNumberController = TextEditingController();
  XFile? _aadhaarFrontPhoto;
  XFile? _aadhaarBackPhoto;
  XFile? _panFrontPhoto;
  XFile? _panBackPhoto;
  XFile? _digitalSign;
  XFile? _selfPhoto;
  bool _consentGiven = false;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _dateOfBirthController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
      ImageSource source, void Function(XFile?) onImageSelected) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        onImageSelected(image);
      });
    }
  }

  Future<String?> _encodeImageToBase64(XFile? imageFile) async {
    if (imageFile == null) return null;
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _submitDataToFirebase() async {
    final String? aadhaarFrontPhotoBase64 =
        await _encodeImageToBase64(_aadhaarFrontPhoto);
    final String? aadhaarBackPhotoBase64 =
        await _encodeImageToBase64(_aadhaarBackPhoto);
    final String? panFrontPhotoBase64 =
        await _encodeImageToBase64(_panFrontPhoto);
    final String? panBackPhotoBase64 =
        await _encodeImageToBase64(_panBackPhoto);
    final String? digitalSignBase64 = await _encodeImageToBase64(_digitalSign);
    final String? selfPhotoBase64 = await _encodeImageToBase64(_selfPhoto);

    final url = Uri.parse(
        'https://kyc-sc-app-default-rtdb.firebaseio.com/submissions.json');

    try {
      final response = await http.post(url,
          body: json.encode({
            'aadhaarNumber': _aadhaarNumberController.text,
            'panNumber': _panNumberController.text,
            'aadhaarFrontPhoto': aadhaarFrontPhotoBase64,
            'aadhaarBackPhoto': aadhaarBackPhotoBase64,
            'panFrontPhoto': panFrontPhotoBase64,
            'panBackPhoto': panBackPhotoBase64,
            'digitalSign': digitalSignBase64,
            'selfPhoto': selfPhotoBase64,
            'consentGiven': _consentGiven,
            'dateOfBirth': _dateOfBirthController.text,
          }));

      if (response.statusCode == 200) {
        // Navigate to success page or show success message
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 6, 27, 1),
      appBar: AppBar(
        title: Text('KYC Form', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(3, 18, 42, 1),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildPage1(),
            _buildPage2(),
            _buildPage3(),
            _buildPage4(),
            _buildPage5(),
            _buildPage6(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(0, 6, 27, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                if (_pageController.page!.toInt() > 0) {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              color: Colors.white,
              onPressed: () async {
                if (_pageController.page!.toInt() < 5) {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                } else {
                  // Ensure form validation before saving
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save(); // Now safely calling save
                    await _submitDataToFirebase();

                    // Show a SnackBar with the success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your data was successfully sent!'),
                        duration: Duration(
                            seconds: 2), // Customize duration if needed
                      ),
                    );

                    // Wait for the SnackBar to be displayed before navigating
                    //await Future.delayed(Duration(seconds: 2));

                    // Navigate to the next screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => VideoScreen()));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _aadhaarNumberController,
            decoration: InputDecoration(
              labelText: 'Aadhaar Card Number',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              border: OutlineInputBorder(),
              // Add errorText dynamically based on the input length.
              errorText: _aadhaarNumberController.text.length > 12
                  ? 'Aadhaar number cannot exceed 12 digits'
                  : null,
            ),
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            // Use onChanged to trigger a UI update when the text changes.
            onChanged: (value) {
              // Trigger a rebuild with setState to show/hide the error message as the user types.
              setState(() {});
            },
          ),
          SizedBox(height: 20),
          _buildPhotoSection(
            'Aadhaar Card Front Photo:',
            _aadhaarFrontPhoto,
            () => _pickImage(
                ImageSource.camera, (xfile) => _aadhaarFrontPhoto = xfile),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPhotoSection(
              'Aadhaar Card Back Photo:',
              _aadhaarBackPhoto,
              () => _pickImage(
                  ImageSource.camera, (xfile) => _aadhaarBackPhoto = xfile)),
          SizedBox(height: 20),
          CheckboxListTile(
            title: Text(
              "I hereby agree that the above document belongs to me and voluntarily give my consent to [company name] to utilize it as my address proof for KYC purpose only",
              style: TextStyle(color: Colors.white),
            ),
            value: _consentGiven,
            onChanged: (bool? value) {
              setState(() {
                _consentGiven = value!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            checkColor: Colors.blue,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _panNumberController,
            decoration: InputDecoration(
              labelText: 'PAN Card Number',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          _buildPhotoSection(
              'PAN Card Front Photo:',
              _panFrontPhoto,
              () => _pickImage(
                  ImageSource.camera, (xfile) => _panFrontPhoto = xfile)),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPhotoSection(
              'PAN Card Back Photo:',
              _panBackPhoto,
              () => _pickImage(
                  ImageSource.camera, (xfile) => _panBackPhoto = xfile)),
        ],
      ),
    );
  }

  Widget _buildPage5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPhotoSection(
              'Digital Signature',
              _digitalSign,
              () => _pickImage(
                  ImageSource.camera, (xfile) => _digitalSign = xfile)),
        ],
      ),
    );
  }

  Widget _buildPage6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPhotoSection(
              'Your Passport Size Photo (recent):',
              _selfPhoto,
              () => _pickImage(
                  ImageSource.camera, (xfile) => _selfPhoto = xfile)),
          SizedBox(height: 20),
          TextFormField(
            controller: _dateOfBirthController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white),
            readOnly: true, // Prevent manual editing
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _dateOfBirthController.text =
                      DateFormat('dd-MM-yyyy').format(pickedDate);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
      String title, XFile? photo, VoidCallback onImagePick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 10),
        InkWell(
          onTap: onImagePick,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlueAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: photo != null
                ? Image.file(File(photo.path), fit: BoxFit.cover)
                : Icon(Icons.camera_alt, size: 50, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
