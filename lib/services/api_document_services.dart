import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:medicom/iomodels/document_model.dart';

class ApiService {
  static const String baseUrl = "https://7nwdrfxr-8000.inc1.devtunnels.ms";
  static Future<String> login({
  required String email,
  required String password,
}) async {
  final url = Uri.parse(
    "$baseUrl/login",
  ).replace(
    queryParameters: {
      "email": email,
      "password": password,
    },
  );

  final response = await http.post(url);
  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(
      data["detail"] ??
          data["message"] ??
          "Login failed",
    );
  }

  return data["message"] ?? "Login failed";
}

  static Future<List<DocumentModel>> getDocuments({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      "$baseUrl/documents",
    ).replace(queryParameters: {"email": email, "password": password});

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data["detail"] ?? data["message"] ?? "Failed to load documents",
      );
    }

    final List documents = data["documents"] ?? [];

    return documents
        .map((document) => DocumentModel.fromJson(document))
        .toList();
  }

  static Future<String> uploadDocument({
    required String email,
    required String password,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-document"),
    );

    request.fields["email"] = email;
    request.fields["password"] = password;

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
        contentType: MediaType("application", "pdf"),
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    if (response.statusCode != 202) {
      throw Exception(data["detail"] ?? data["message"] ?? "Upload failed");
    }

    return data["message"] ?? "Document uploaded successfully";
  }

  static Future<String> updateDocument({
    required String documentId,
    required String email,
    required String password,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      "PATCH",
      Uri.parse("$baseUrl/documents/$documentId"),
    );

    request.fields["email"] = email;
    request.fields["password"] = password;

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
        contentType: MediaType("application", "pdf"),
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    if (response.statusCode != 200) {
      throw Exception(
        data["detail"] ?? data["message"] ?? "Document update failed",
      );
    }

    return data["message"] ?? "Document updated successfully";
  }

  static Future<String> deleteDocument({
    required String documentId,
    required String email,
    required String password,
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/documents/$documentId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data["detail"] ?? data["message"] ?? "Document deletion failed",
      );
    }

    return data["message"] ?? "Document deleted successfully";
  }

  static Future<String> sendOtp({
  required String email,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/send-otp"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
    }),
  );

  if (response.statusCode != 200) {
    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data["detail"] ??
            data["message"] ??
            "Failed to send OTP",
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : "Failed to send OTP",
      );
    }
  }

  if (response.body.isEmpty) {
    return "OTP sent successfully";
  }

  try {
    final data = jsonDecode(response.body);

    return data["message"] ??
        "OTP sent successfully";
  } catch (_) {
    return response.body;
  }
}

  static Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify_otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data["detail"] ?? data["message"] ?? "OTP verification failed",
      );
    }

    return data["message"] ?? "OTP verification completed";
  }

  static Future<String> changePassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/change-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data["detail"] ?? data["message"] ?? "Password change failed",
      );
    }

    return data["message"] ?? "Password changed successfully";
  }
}
