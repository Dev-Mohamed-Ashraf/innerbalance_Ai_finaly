import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:innerbalance/core/services/face_recognition_service.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:image/image.dart' as img;

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // Use front camera if available
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndVerify() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
        _resultMessage = null;
      });

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      
      await _initializeControllerFuture;
      final capturedImage = await _controller!.takePicture();
      
      final service = sl<FaceRecognitionService>();
      await service.initialize(); // Ensure initialized
      
      // Pass the XFile directly to the service
      // The service implementation should handle reading bytes/decoding if needed
      // Note: On web, this will return null immediately.
      final result = await service.predict(capturedImage);
      
      setState(() {
        if (result != null) {
           _resultMessage = 'Face Verified! User: $result';
        } else {
           _resultMessage = 'Face Not Recognized or Not Supported on Web';
        }
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_resultMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _resultMessage!,
                      style: TextStyle(
                        color: _resultMessage!.startsWith('Error') ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _captureAndVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Capture & Verify', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
