import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PythonApiService {
  // REPLACE THIS WITH YOUR PC's IP ADDRESS IF USING REAL DEVICE
  // For Emulator use: 'http://10.0.2.2:5000'
  // For Real Device use: 'http://192.168.100.3:5000' (Your current IP)
  static const String baseUrl = 'http://192.168.100.3:5000';

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/analyze');
    
    var request = http.MultipartRequest('POST', uri);
    
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Decode with UTF-8 to support Arabic
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to AI Server: $e');
    }
  }

  String getImageUrl(String relativePath) {
    return '$baseUrl$relativePath';
  }
}
