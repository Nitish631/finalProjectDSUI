import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:medicom/iomodels/document_model.dart";

class ApiService {
  static const String baseUrl =
      "https://7nwdrfxr-8000.inc1.devtunnels.ms";

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

    try {
      final response = await http.post(url);

      try {
        final data = jsonDecode(response.body);

        return data["message"] ??
            data["detail"] ??
            "Login failed";
      } catch (_) {
        return response.body.isNotEmpty
            ? response.body
            : "Login failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<List<DocumentModel>> getDocuments({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      "$baseUrl/documents",
    ).replace(
      queryParameters: {
        "email": email,
        "password": password,
      },
    );

    try {
      final response = await http.get(url);

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode != 200) {
          return [];
        }

        final List documents = data["documents"] ?? [];

        return documents
            .map(
              (document) => DocumentModel.fromJson(document),
            )
            .toList();
      } catch (_) {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  static Future<String> uploadDocument({
    required String email,
    required String password,
    required File file,
  }) async {
    try {
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
          contentType: MediaType(
            "application",
            "pdf",
          ),
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      try {
        final data = jsonDecode(responseBody);

        return data["message"] ??
            data["detail"] ??
            "Upload failed";
      } catch (_) {
        return responseBody.isNotEmpty
            ? responseBody
            : "Upload failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<String> updateDocument({
    required String documentId,
    required String email,
    required String password,
    required File file,
  }) async {
    try {
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
          contentType: MediaType(
            "application",
            "pdf",
          ),
        ),
      );

      final response = await request.send();

      final responseBody =
          await response.stream.bytesToString();

      try {
        final data = jsonDecode(responseBody);

        return data["message"] ??
            data["detail"] ??
            "Document update failed";
      } catch (_) {
        return responseBody.isNotEmpty
            ? responseBody
            : "Document update failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<String> deleteDocument({
    required String documentId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/documents/$documentId"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      try {
        final data = jsonDecode(response.body);

        return data["message"] ??
            data["detail"] ??
            "Document deletion failed";
      } catch (_) {
        return response.body.isNotEmpty
            ? response.body
            : "Document deletion failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<String> sendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      try {
        final data = jsonDecode(response.body);

        return data["message"] ??
            data["detail"] ??
            "Failed to send OTP";
      } catch (_) {
        return response.body.isNotEmpty
            ? response.body
            : "Failed to send OTP";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify_otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );

      try {
        final data = jsonDecode(response.body);

        return data["message"] ??
            data["detail"] ??
            "OTP verification failed";
      } catch (_) {
        return response.body.isNotEmpty
            ? response.body
            : "OTP verification failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }

  static Future<String> changePassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "password": password,
        }),
      );

      try {
        final data = jsonDecode(response.body);

        return data["message"] ??
            data["detail"] ??
            "Password change failed";
      } catch (_) {
        return response.body.isNotEmpty
            ? response.body
            : "Password change failed";
      }
    } catch (_) {
      return "Unable to connect to server";
    }
  }
}