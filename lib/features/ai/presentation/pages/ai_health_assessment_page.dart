import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:innerbalance/core/services/ai_engine_service.dart';
import 'package:innerbalance/core/services/service_locator.dart';

class AIHealthAssessmentPage extends StatefulWidget {
  const AIHealthAssessmentPage({super.key});

  @override
  State<AIHealthAssessmentPage> createState() => _AIHealthAssessmentPageState();
}

class _AIHealthAssessmentPageState extends State<AIHealthAssessmentPage> {
  File? _selectedImage;
  String? _analyzedImagePath;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analyzedImagePath = null;
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final res = await sl<AiEngineService>().analyzeImage(_selectedImage!.path);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          if (res.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${res['error']}')),
            );
          } else {
            _analyzedImagePath = res['analyzed_image_path'];
            _analysisResult = res['result'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليل الصحي بالذكاء الاصطناعي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Privacy Notice
            _buildInfoCard(
              Icons.privacy_tip,
              'خصوصيتك مهمة: الصور لا يتم حفظها وتُحذف تلقائياً بعد التحليل',
              Colors.blue,
            ),
            const SizedBox(height: 24),

            // Image Selection or Preview
            if (_selectedImage == null && _analysisResult == null)
              _buildImagePickerUI()
            else if (_selectedImage != null || _analyzedImagePath != null)
              _buildImagePreviewUI(),

            // Analysis Results
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              _buildResultUI(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color.withOpacity(0.9), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerUI() {
    return Column(
      children: [
        const Text(
          'اختر طريقة التقاط الصورة:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPickerButton(
                Icons.camera_alt,
                'التقاط صورة',
                () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPickerButton(
                Icons.photo_library,
                'اختيار من المعرض',
                () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
    );
  }

  Widget _buildImagePreviewUI() {
    final imageToDisplay = _analyzedImagePath != null ? File(_analyzedImagePath!) : _selectedImage!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _analyzedImagePath != null ? 'الصورة المحللة (مع كشف الملامح):' : 'الصورة المختارة:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(imageToDisplay, height: 350, width: double.infinity, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        if (_analysisResult == null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  icon: _isAnalyzing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.analytics),
                  label: Text(_isAnalyzing ? 'جاري التحليل...' : 'بدء التحليل الذكي'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResultUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('نتائج التحليل الطبي الذكي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          _buildScoreRow('احتمالية التأثر الصحي', '${_analysisResult!['addiction_probability_percentage']}%'),
          _buildScoreRow('مستوى الخطورة', _analysisResult!['urgency_level']),
          const SizedBox(height: 16),
          const Text('التقرير المفصل:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_analysisResult!['overall_analysis'] ?? '', style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
          const Text('المؤشرات المكتشفة:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...(_analysisResult!['indicators'] as Map<String, dynamic>).entries.map((e) => _buildIndicatorCard(e.key, e.value)),
          const SizedBox(height: 24),
          _buildInfoCard(Icons.warning_amber_rounded, _analysisResult!['disclaimer'] ?? '', Colors.orange),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _selectedImage = null;
              _analyzedImagePath = null;
              _analysisResult = null;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('تحليل صورة جديدة'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String type, dynamic data) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        title: Text(_translateIndicator(type), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(data['description'] ?? ''),
        trailing: data['severity'] != null ? Text('${data['severity']}%', style: const TextStyle(color: Colors.red)) : null,
      ),
    );
  }

  String _translateIndicator(String type) {
    switch (type) {
      case 'dark_circles': return 'الهالات السوداء';
      case 'eye_redness': return 'احمرار العين';
      case 'weight_loss_signs': return 'علامات نحافة الوجه';
      case 'skin_condition': return 'حالة الجلد';
      case 'mouth_teeth_condition': return 'حالة الفم والأسنان';
      default: return type;
    }
  }
}
