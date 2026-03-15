import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiEngineService {
  /// يقوم بتحليل الصورة (رسم المربعات + التشخيص الطبي من Gemini)
  /// يعيد المسار الجديد للصورة واسم ملف النتيجة (JSON).
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return {'error': 'لم يتم العثور على الصورة.'};
    }

    try {
      // 1. مرحلة الرؤية الحاسوبية (ML Kit) لاكتشاف الوجه ورسم المربعات
      final String analyzedImagePath = await _processImageWithMLKit(imagePath);

      // 2. مرحلة التحليل الطبي (Gemini AI)
      final String aiResult = await _analyzeWithGemini(analyzedImagePath);

      return {
        'analyzed_image_path': analyzedImagePath,
        'result': jsonDecode(aiResult),
      };
    } catch (e) {
      return {'error': 'حدث خطأ أثناء التحليل: $e'};
    }
  }

  /// هذه الدالة تستبدل OpenCV.
  /// تكتشف الوجه وترسم المربعات (أخضر للوجه، أحمر للعيون، أزرق للفم)
  Future<String> _processImageWithMLKit(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    
    // إعداد أداة اكتشاف الوجه (مطلوب النقاط البارزة كالعيون والفم)
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    final faceDetector = FaceDetector(options: options);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    // إذا لم يجد وجهاً سيُكمل على الصورة الأصلية (نفس منطق Python Fallback)
    if (faces.isEmpty) return imagePath;

    // قراءة الصورة للرسم عليها باستخدام مكتبة image
    final originalBytes = await File(imagePath).readAsBytes();
    final img.Image? decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return imagePath;

    for (Face face in faces) {
      // 1. رسم مربع أخضر حول الوجه (Face Bounding Box)
      final rect = face.boundingBox;
      img.drawRect(
        decodedImage,
        x1: rect.left.toInt(),
        y1: rect.top.toInt(),
        x2: rect.right.toInt(),
        y2: rect.bottom.toInt(),
        color: img.ColorRgb8(0, 255, 0),
        thickness: 4,
      );

      // 2. رسم دوائر حمراء على العيون
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye != null) {
        img.drawCircle(
            decodedImage,
            x: leftEye.position.x.toInt(),
            y: leftEye.position.y.toInt(),
            radius: 20,
            color: img.ColorRgb8(255, 0, 0));
      }
      if (rightEye != null) {
        img.drawCircle(
            decodedImage,
            x: rightEye.position.x.toInt(),
            y: rightEye.position.y.toInt(),
            radius: 20,
            color: img.ColorRgb8(255, 0, 0));
      }

      // 3. رسم مربع أزرق حول الفم
      final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];
      final rightMouth = face.landmarks[FaceLandmarkType.rightMouth];
      final leftMouth = face.landmarks[FaceLandmarkType.leftMouth];

      if (bottomMouth != null && rightMouth != null && leftMouth != null) {
        img.drawRect(
          decodedImage,
          x1: leftMouth.position.x.toInt() - 10,
          y1: leftMouth.position.y.toInt() - 20,
          x2: rightMouth.position.x.toInt() + 10,
          y2: bottomMouth.position.y.toInt() + 10,
          color: img.ColorRgb8(0, 0, 255),
          thickness: 3,
        );
      }
    }

    // حفظ الصورة الجديدة
    final directory = File(imagePath).parent.path;
    final String newPath = '$directory/analyzed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(newPath).writeAsBytes(img.encodeJpg(decodedImage, quality: 90));

    return newPath;
  }

  /// هذه الدالة تستبدل requests للاتصال بـ Gemini API
  Future<String> _analyzeWithGemini(String imagePath) async {
    // يجب استدعاء await dotenv.load() في بداية التطبيق (Main)
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('لم يتم العثور على GEMINI_API_KEY');
    }

    // استخدام الموديل المتوفر لديك
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // تحضير الصورة
    final imageBytes = await File(imagePath).readAsBytes();
    final imageParts = [
      DataPart('image/jpeg', imageBytes),
    ];

    final promptText = """
        أنت مساعد طبي ذكي متخصص في تحليل علامات الإدمان والأمراض الظاهرة على الوجه.
        قم بتحليل الصورة المرفقة بدقة عالية جداً للبحث عن مؤشرات حيوية قد تدل على تعاطي المخدرات أو الإرهاق الشديد.

        قم بتقييم المؤشرات التالية بدقة:
        1. **الهالات السوداء (Dark Circles)**: الشدة (0-100%)، اللون (بنفسجي/أسود/أزرق).
        2. **احمرار العين (Eye Redness)**: الشدة (0-100%)، هل هو احمرار دائم أم مؤقت؟
        3. **نحافة الوجه (Facial Wasting)**: هل يوجد ضمور في الخدود أو نحافة غير طبيعية؟
        4. **حالة الجلد (Skin Condition)**: هل توجد حبوب، جروح، شحوب، أو آثار هرش (Skin Picking)؟
        5. **حالة الأسنان والفم (Dental/Mouth)**: إذا كانت ظاهرة، هل يوجد تآكل أو جفاف شديد؟

        بناءً على هذه العوامل، قدم تقييماً نظرياً لاحتمالية الإدمان ومستوى الخطورة.

        **مهم جداً**: يجب أن تكون النتيجة بصيغة JSON فقط وبدون أي نصوص إضافية. القيم النصية يجب أن تكون **باللغة العربية**.

        JSON Structure:
        {
            "addiction_probability_percentage": <number 0-100>,
            "confidence_score": <number 0-100>,
            "urgency_level": "<High/Medium/Low> - <عالي/متوسط/منخفض>",
            "indicators": {
                "dark_circles": { "severity": <0-100>, "description": "...وصف دقيق بالعربية..." },
                "eye_redness": { "severity": <0-100>, "description": "...وصف دقيق بالعربية..." },
                "weight_loss_signs": { "detected": <true/false>, "description": "...وصف دقيق بالعربية..." },
                "skin_condition": { "description": "...وصف دقيق بالعربية (حبوب/جروح/شحوب)..." },
                "mouth_teeth_condition": { "description": "...وصف دقيق بالعربية (إذا ظهرت)..." }
            },
            "overall_analysis": "...تقرير طبي شامل ومفصل باللغة العربية يشرح الحالة ويربط الأعراض ببعضها...",
            "recommendation": "...نصيحة طبية مختصرة بالعربية...",
            "disclaimer": "هذا التحليل تم بواسطة الذكاء الاصطناعي لأغراض استرشادية فقط ولا يعتبر تشخيصاً طبياً نهائياً. يرجى مراجعة طبيب مختص."
        }
    """;

    final content = [
      Content.multi([TextPart(promptText), ...imageParts])
    ];

    final response = await model.generateContent(content);
    String resultText = response.text ?? '';

    // تنظيف النتيجة من أي علامات Markdown قديفهمها Dart كخطأ
    resultText = resultText.trim();
    if (resultText.startsWith('```json')) {
      resultText = resultText.substring(7);
    }
    if (resultText.startsWith('```')) {
      resultText = resultText.substring(3);
    }
    if (resultText.endsWith('```')) {
      resultText = resultText.substring(0, resultText.length - 3);
    }
    return resultText;
  }
}

