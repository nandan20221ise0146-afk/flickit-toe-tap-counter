
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class YoloService {
  static const String apiKey =
      String.fromEnvironment('ROBOFLOW_API_KEY');

  static const String modelId = 'feet-6wfx2-o8v2z';
  static const String version = '1';

  Future<Map<String, dynamic>> detectFeet(File imageFile) async {
    if (apiKey.isEmpty) {
      throw Exception('Missing Roboflow API key.');
    }

    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist.');
    }

    final url = Uri.https(
      'detect.roboflow.com',
      '/$modelId/$version',
      {'api_key': apiKey},
    );

    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Roboflow HTTP Status: ${response.statusCode}');
    print('Roboflow Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Roboflow error ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  int getFeetCount(Map<String, dynamic> result) {
    final predictions = result['predictions'] as List? ?? [];

    return predictions.where((prediction) {
      if (prediction is! Map) return false;

      final label = prediction['class']?.toString().toLowerCase() ?? '';

      return label == 'feet' || label == 'foot';
    }).length;
  }
}
