import 'dart:convert';
import 'package:http/http.dart' as http;
import 'apis.dart';

class ThesaurusExtra {
  static Future<List<Map<String, dynamic>>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.domains));
      if (response.statusCode != 200) return [];
      final decoded = utf8.decode(response.bodyBytes);
      final body = json.decode(decoded);
      final data = body['data'];
      if (data is! List) return [];
      return data.map((item) {
        final map = item as Map<String, dynamic>;
        return {
          'id': map['id'],
          'title': map['title']?.toString() ?? '',
          'color': map['color']?.toString(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> login(String username, String password) async {
    final url = ApiUrls.login;
    if (url.isEmpty) return false;
    try {
      final res = await http.post(Uri.parse(url), body: {
        'username': username,
        'password': password,
        'service': 'https://adminthesaurus.isca.ac.ir/login',
      });
      if (res.statusCode == 200) {
        final body = json.decode(utf8.decode(res.bodyBytes));
        return body['success'] == true || res.body.contains('success');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(String username, String password, String email) async {
    final url = ApiUrls.register;
    if (url.isEmpty) return false;
    try {
      final res = await http.post(Uri.parse(url), body: {
        'username': username,
        'password': password,
        'email': email,
      });
      if (res.statusCode == 200 && res.body.contains('success')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    final url = ApiUrls.forgotPassword;
    if (url.isEmpty) return false;
    try {
      final res = await http.post(Uri.parse(url), body: {'email': email});
      if (res.statusCode == 200) {
        final decoded = utf8.decode(res.bodyBytes);
        final body = json.decode(decoded);
        return body['success'] == true || res.body.contains('success');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
