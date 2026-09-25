import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medicom/iomodels/prompt_model.dart';
import "package:medicom/data/constant.dart" as constant;

String baseUrl = constant.baseUrl;

Future<FirstAidResponse> sendMessage(FirstAidRequest request) async {
  final url = Uri.parse(baseUrl + "/first_aid");
  final client = http.Client();

  try {
    print("Sending request to: $url");
    print("Request started: ${DateTime.now()}");

    final httpRequest = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(request.toJson());

    final streamedResponse = await client.send(httpRequest).timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        throw TimeoutException('Request exceeded 10 minutes');
      },
    );
    print("Stream established: ${DateTime.now()}");
    print("Status code: ${streamedResponse.statusCode}");

    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw Exception('Server error: ${streamedResponse.statusCode}\n$errorBody');
    }

    final StringBuffer buffer = StringBuffer();
    await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer.write(chunk);
    }

    final finalResponseBody = buffer.toString().trim();
    print("Full response body received: ${DateTime.now()}");

    if (finalResponseBody.isEmpty) {
      throw Exception('Server returned an empty response.');
    }

    return FirstAidResponse.fromJson(
      jsonDecode(finalResponseBody),
    );

  } on TimeoutException catch (e) {
    print("TIMEOUT: $e");
    throw Exception('The request took more than 10 minutes.');
  } catch (e) {
    print("ERROR: $e");
    rethrow;
  } finally {
    client.close(); 
  }
}


String getImageUrl(String path) {
  return baseUrl + path;
  
}