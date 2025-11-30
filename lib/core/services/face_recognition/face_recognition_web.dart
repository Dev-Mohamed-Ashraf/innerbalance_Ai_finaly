import 'face_recognition_interface.dart';

class FaceRecognitionServiceImpl implements FaceRecognitionService {
  @override
  Future<void> initialize() async {
    print('Face Recognition not supported on Web');
  }

  @override
  Future<dynamic> registerFace(dynamic image, String name) async {
    return null;
  }

  @override
  Future<String?> predict(dynamic image) async {
    return null;
  }
}
