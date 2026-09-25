import "package:flutter/material.dart";
import "package:medicom/data/constant.dart" as constant;
import "package:medicom/data/database.dart";
import "package:medicom/iomodels/prompt_model.dart";
import "package:medicom/screens/admin_home_screen.dart";
import "package:medicom/screens/login_screen.dart";
import "package:medicom/services/api_document_services.dart";
import "package:medicom/services/api_prompt_services.dart";
import "package:medicom/services/speech.dart";
import "package:medicom/services/ttsx.dart";

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SpeechService speechService = SpeechService();
  final TtsService ttsService = TtsService();

  List<String> imagePaths = [];
  List<ChatMessage> chatHistory = [];

  String recognizedText = "";

  late FirstAidResponse firstAidResponse;

  bool isListening = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    ttsService.initialize();
    speechService.initialize();
  }

  Future<void> startListening() async {
    await ttsService.stop();

    setState(() {
      imagePaths.clear();
      recognizedText = '';
      isListening = true;
    });

    await speechService.startListening(
      onResult: (text) {
        if (!mounted) return;

        setState(() {
          recognizedText = text;
        });
      },
    );
  }

  Future<void> stopListening() async {
    final finalText = await speechService.stopListening();

    if (!mounted) return;

    setState(() {
      recognizedText = finalText;
      isListening = false;
    });
  }

  Future<void> sendRequest() async {
    if (recognizedText.trim().isEmpty) {
      return;
    }

    final finalText = recognizedText.trim();

    setState(() {
      isSending = true;
    });

    final request = FirstAidRequest(query: finalText, messages: chatHistory);

    try {
      final response = await sendMessage(request);

      if (!mounted) return;

      setState(() {
        firstAidResponse = response;
        chatHistory = response.chatHistory;
        imagePaths = response.imagePaths;
        recognizedText = '';
        isSending = false;
      });

      await ttsService.speak(response.response);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        recognizedText = "";
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text("Request failed:\n$error"),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void clearRecognizedText() {
    setState(() {
      recognizedText = '';
    });
  }

  Future<void> openAdmin() async {
    final credentials = await AdminDatabase().getCredentials();

    if (!mounted) {
      return;
    }

    if (credentials == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final email = credentials["email"]!;
    final password = credentials["password"]!;

    try {
      final message = await ApiService.login(email: email, password: password);

      if (!mounted) {
        return;
      }
      print("\n\n\n\n\n");
      print(message);
      print("\n\n\n\n\n");
      if (message == "Login Successful") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomeScreen(email: email, password: password),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constant.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: imagePaths.isNotEmpty
                      ? Column(
                          children: imagePaths
                              .map(
                                (path) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Image.network(
                                    getImageUrl(path),
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            "Unable to load image",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const SizedBox(),
                ),
              ),
            ),

            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: openAdmin,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: constant.adminButtonBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: constant.adminButtonColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 500,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                  child: Text(
                    recognizedText.isEmpty
                        ? "Press and hold the microphone and speak..."
                        : recognizedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),

            if (isSending)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (recognizedText.trim().isNotEmpty && !isListening)
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: constant.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: Dismissible(
                            key: ValueKey(recognizedText),
                            direction: DismissDirection.horizontal,
                            dismissThresholds: const {
                              DismissDirection.startToEnd: 0.35,
                              DismissDirection.endToStart: 0.35,
                            },
                            background: Container(
                              decoration: BoxDecoration(
                                color: constant.greenSwap,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 15),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 15),
                            ),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                sendRequest();
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                setState(() {
                                  recognizedText = '';
                                });
                              }
                            },
                            child: Center(
                              child: Container(
                                height: 55,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color: constant.backgroundColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.swap_horiz,
                                    color: constant.backgroundColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: constant.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTapDown: (_) async {
                      await ttsService.stop();

                      setState(() {
                        imagePaths.clear();
                        recognizedText = '';
                        isListening = true;
                      });

                      await speechService.startListening(
                        onResult: (text) {
                          if (!mounted) return;

                          setState(() {
                            recognizedText = text;
                          });
                        },
                      );
                    },
                    onTapUp: (_) async {
                      if (!isListening) return;

                      final finalText = await speechService.stopListening();

                      if (!mounted) return;

                      setState(() {
                        recognizedText = finalText;
                        isListening = false;
                      });
                    },
                    onTapCancel: () async {
                      if (!isListening) return;

                      final finalText = await speechService.stopListening();

                      if (!mounted) return;

                      setState(() {
                        recognizedText = finalText;
                        isListening = false;
                      });
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: constant.buttonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Center(
                        child: Icon(Icons.mic, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
