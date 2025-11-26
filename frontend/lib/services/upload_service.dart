import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class UploadService {
  static const String baseUrl = 'http://localhost:8080/api/screenshots';

  static Future<Map<String, dynamic>> uploadScreenshot({
    required File file,
    required String title,
    String? description,
    String? userId,
    String? category,
    double? amount,
    String? currency,
    DateTime? billDate,
    String? vendor,
    Map<String, String>? tags,
  }) async {
    try {
      final dio = Dio();
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'title': title,
        if (description != null) 'description': description,
        if (userId != null) 'userId': userId,
        if (category != null) 'category': category,
        if (amount != null) 'amount': amount.toString(),
        if (currency != null) 'currency': currency,
        if (billDate != null) 'billDate': billDate.toIso8601String(),
        if (vendor != null) 'vendor': vendor,
      });

      // Add tags if present
      if (tags != null) {
        tags.forEach((key, value) {
          formData.fields.add(MapEntry('tags[$key]', value));
        });
      }

      final response = await dio.post(
        '$baseUrl/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to upload screenshot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading screenshot: $e');
    }
  }
}
