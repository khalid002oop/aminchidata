import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/storage.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  ApiResponse({required this.success, required this.message, this.data});
}

class ApiClient {
  static Future<Map<String, String>> _headers({bool auth = true, String? overrideToken}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final token = overrideToken ?? await Storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static ApiResponse _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResponse(
        success: body['success'] == true,
        message: body['message'] ?? '',
        data: body['data'],
      );
    } catch (_) {
      return ApiResponse(success: false, message: 'Server error. Please try again.', data: null);
    }
  }

  static Future<ApiResponse> get(String path, {Map<String, String>? query, String? token}) async {
    var uri = Uri.parse(ApiConstants.baseUrl + path);
    if (query != null && query.isNotEmpty) uri = uri.replace(queryParameters: query);
    try {
      final res = await http.get(uri, headers: await _headers(overrideToken: token)).timeout(const Duration(seconds: 30));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error. Check your connection.', data: null);
    }
  }

  static Future<ApiResponse> post(String path, Map<String, dynamic> body, {bool auth = true, String? token}) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    try {
      final res = await http.post(uri, headers: await _headers(auth: auth, overrideToken: token), body: jsonEncode(body)).timeout(const Duration(seconds: 60));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error. Check your connection.', data: null);
    }
  }
}
