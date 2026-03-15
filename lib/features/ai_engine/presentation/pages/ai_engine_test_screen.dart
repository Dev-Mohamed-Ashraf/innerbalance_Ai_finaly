import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:innerbalance/core/services/ai_engine_service.dart';
import 'package:innerbalance/core/services/service_locator.dart';

class AiEngineTestScreen extends StatefulWidget {
  const AiEngineTestScreen({super.key});

  @override
  State<AiEngineTestScreen> createState() => _AiEngineTestScreenState();
}

class _AiEngineTestScreenState extends State<AiEngineTestScreen> {
  File? _image;
  String? _analyzedImagePath;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
        _analyzedImagePath = null;
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final res = await sl<AiEngineService>().analyzeImage(_image!.path);

    setState(() {
      _isLoading = false;
      if (res.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res['error']}')),
        );
      } else {
        _analyzedImagePath = res['analyzed_image_path'];
        _result = res['result'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار محرك الذكاء الاصطناعي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null && _analyzedImagePath == null) ...[
              const Text('الصورة المختارة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.file(_image!, height: 300, fit: BoxFit.contain),
            ],
            if (_analyzedImagePath != null) ...[
              const Text('الصورة المحللة (مع المربعات):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 8),
              Image.file(File(_analyzedImagePath!), height: 300, fit: BoxFit.contain),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('اختار صورة من الاستوديو'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_image == null || _isLoading) ? null : _analyzeImage,
              icon: const Icon(Icons.analytics),
              label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('بدء التحليل الذكي'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Text('نتائج التحليل:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildResultItem('نسبة احتمالية الإدمان', '${_result!['addiction_probability_percentage']}%'),
              _buildResultItem('مستوى الخطورة', _result!['urgency_level']),
              _buildResultItem('التحليل العام', _result!['overall_analysis']),
              const SizedBox(height: 16),
              const Text('المؤشرات:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(_result!['indicators'] as Map<String, dynamic>).entries.map((e) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(e.value['description'] ?? ''),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
