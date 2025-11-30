abstract class FaceRecognitionService {
  Future<void> initialize();
  Future<dynamic> registerFace(dynamic image, String name);
  Future<String?> predict(dynamic image);
}
