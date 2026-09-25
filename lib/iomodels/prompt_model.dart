class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(role: json['role'], content: json['content']);
  }
  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class FirstAidRequest {
  final String query;
  List<ChatMessage> messages;
  FirstAidRequest({required this.query, this.messages = const []});

  factory FirstAidRequest.fromJson(Map<String, dynamic> json) {
    return FirstAidRequest(
      query: json['query'],
      messages: (json['messages'] as List<dynamic>)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}



class FirstAidResponse {
  final String response;
  List<String> imagePaths;
  final List<ChatMessage> chatHistory;

  FirstAidResponse({
    required this.response,
    this.imagePaths = const [],
    required this.chatHistory,
  });

  factory FirstAidResponse.fromJson(Map<String, dynamic> json) {
    return FirstAidResponse(
      response: json['response'] ?? '',

      imagePaths: List<String>.from(
        json['image_paths'] ?? [],
      ),

      chatHistory: (json['chat_history'] as List<dynamic>? ?? [])
          .map(
            (messageJson) =>
                ChatMessage.fromJson(messageJson),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'image_paths': imagePaths,
      'chat_history': chatHistory
          .map((message) => message.toJson())
          .toList(),
    };
  }
}