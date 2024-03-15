import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:kyc_app/KYCverifiedScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  Color _outlineColor = Colors.transparent; // State for the outline color

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus == PermissionStatus.granted &&
        microphoneStatus == PermissionStatus.granted) {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController?.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });

      // Start a timer to change the outline color to green after 10 seconds
      Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _outlineColor = Colors.green;
          });
        }
      });
    } else {
      print('Camera or Microphone permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 6, 27, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 6, 27, 1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showCamera || !_isCameraInitialized)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Kindly provide your camera and microphone permissions to proceed.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: const Text('Start Video'),
                        leading: const Icon(Icons.videocam),
                        onTap: () {
                          if (!_showCamera) {
                            setState(() {
                              _showCamera = true;
                            });
                            _initCamera();
                          }
                        },
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            if (_showCamera && _isCameraInitialized)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _outlineColor, width: 3),
                ),
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            if (_showCamera && _isCameraInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Please note that we are monitoring this camera feed',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            if (_showCamera && _isCameraInitialized)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the "Accept and Continue" action
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => KYCVerifiedScreen()));
                  },
                  child: const Text('Accept and Continue'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
