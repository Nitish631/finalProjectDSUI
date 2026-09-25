import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medicom/iomodels/prompt_model.dart';
import "package:medicom/data/constant.dart" as constant;
String baseUrl=constant.baseUrl;
Future<FirstAidResponse> sendMessage(FirstAidRequest request)async {
  final url = Uri.parse(baseUrl + "/first_aid");
  final response =await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(request.toJson()),
  );
  if (response.statusCode == 200) {
    final firstAidResponse= FirstAidResponse.fromJson(jsonDecode(response.body));
    return firstAidResponse;
  } else {
    throw Exception('Failed to send message: ${response.statusCode}');
  }
}

String getImageUrl(String path) {
  return baseUrl + path;
}