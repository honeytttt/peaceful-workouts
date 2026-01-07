import 'package:http/http.dart' as http;

class HttpService {
  static Future<http.Response> post(String url, Map<String, String> body) async {
    return await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
  }
  
  static Future<http.Response> get(String url) async {
    return await http.get(Uri.parse(url));
  }
}