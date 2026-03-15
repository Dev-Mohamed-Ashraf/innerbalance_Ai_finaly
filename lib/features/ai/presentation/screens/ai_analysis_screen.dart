import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:innerbalancee/core/api/python_api_service.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  final PythonApiService _apiService = PythonApiService();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null; // Reset previous result
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.analyzeImage(_selectedImage!);
      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Addiction Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload image'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Analyze Button
            ElevatedButton(
              onPressed: _isLoading || _selectedImage == null ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze Now', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),

            // Results Section
            if (_result != null) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    final percentage = _result!['addiction_probability_percentage'] ?? 0;
    final urgency = _result!['urgency_level'] ?? 'Unknown';
    final analysis = _result!['overall_analysis'] ?? '';
    final imageUrl = _result!['analyzed_image_url'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Center(
          child: Text(
            'Analysis Result',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        
        // Analyzed Image (Visual Evidence)
        if (imageUrl != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _apiService.getImageUrl(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Center(child: Text('Could not load analyzed image')),
              ),
            ),
          ),

        // Risk Indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: percentage > 50 ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: percentage > 50 ? Colors.red : Colors.green),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Risk Level', style: TextStyle(fontSize: 16)),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: percentage > 50 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Urgency', style: TextStyle(fontSize: 16)),
                  Text(
                    urgency,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detailed Report
        const Text('Medical Report:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            analysis,
            style: const TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.right, // Arabic support
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(height: 20),

        // Detailed Indicators Section
        const Text('Detailed Indicators:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildIndicatorsList(_result!['indicators']),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildIndicatorsList(Map<String, dynamic>? indicators) {
    if (indicators == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildIndicatorCard(
          title: 'Dark Circles',
          arabicTitle: 'الهالات السوداء',
          icon: Icons.remove_red_eye,
          data: indicators['dark_circles'],
        ),
        _buildIndicatorCard(
          title: 'Eye Redness',
          arabicTitle: 'احمرار العين',
          icon: Icons.visibility_off,
          data: indicators['eye_redness'],
        ),
        _buildIndicatorCard(
          title: 'Skin Condition',
          arabicTitle: 'حالة الجلد',
          icon: Icons.face,
          data: indicators['skin_condition'],
          hasSeverity: false,
        ),
        _buildIndicatorCard(
          title: 'Weight Loss',
          arabicTitle: 'نحافة الوجه',
          icon: Icons.person_outline,
          data: indicators['weight_loss_signs'],
          hasSeverity: false,
        ),
        _buildIndicatorCard(
          title: 'Mouth & Teeth',
          arabicTitle: 'الفم والأسنان',
          icon: Icons.sentiment_very_dissatisfied,
          data: indicators['mouth_teeth_condition'],
          hasSeverity: false,
        ),
      ],
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required String arabicTitle,
    required IconData icon,
    required Map<String, dynamic>? data,
    bool hasSeverity = true,
  }) {
    if (data == null) return const SizedBox.shrink();

    final severity = data['severity'] ?? 0;
    final description = data['description'] ?? 'No data';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align for Arabic
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasSeverity)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$severity%',
                      style: TextStyle(
                        color: _getSeverityColor(severity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Row(
                  children: [
                    Text(
                      arabicTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.blueGrey),
                  ],
                ),
              ],
            ),
            if (hasSeverity) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: severity / 100,
                backgroundColor: Colors.grey[200],
                color: _getSeverityColor(severity),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity < 30) return Colors.green;
    if (severity < 60) return Colors.orange;
    return Colors.red;
  }
}
