import "package:flutter/material.dart";
import "package:medicom/api.dart";
import "package:medicom/speech.dart";
import "package:medicom/ttsx.dart";

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Color backgroundColor = Color.fromRGBO(45, 101, 56, 1);
  final SpeechService speechService = SpeechService();
  final TtsService ttsService = TtsService();

  List<String> imagePaths = [];
  List<ChatMessage> chatHistory = [];
  String recognizedText = '';
  late FirstAidResponse firstAidResponse;
  @override
  void initState() {
    super.initState();

    ttsService.initialize();
    speechService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              color: backgroundColor,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: (imagePaths.isNotEmpty)
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Column(children: []),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 0,
              left: 0,
              child: Container(
                width: 300,
                height: 300,
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Center(
                  child: InkWell(
                    onTapDown: (detail) async {
                      await ttsService.stop();

                      setState(() {
                        imagePaths.clear();
                        recognizedText = '';
                      });

                      await speechService.startListening(
                        onResult: (text) {
                          setState(() {
                            recognizedText = text;
                          });
                        },
                      );
                    },
                    onTapUp: (detail) async {
                      try {
                        final finalText = await speechService.stopListening();

                        if (finalText.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No speech detected")),
                          );
                          return;
                        }

                        setState(() {
                          recognizedText = finalText;
                        });

                        final request = FirstAidRequest(
                          query: finalText,
                          messages: chatHistory,
                        );

                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (!mounted) return;

                          setState(() {
                            recognizedText = '';
                          });
                        });

                        try {
                          final response = await sendMessage(request);

                          setState(() {
                            firstAidResponse = response;
                            chatHistory = response.chatHistory;
                            imagePaths = response.imagePaths;
                          });

                          await ttsService.speak(response.response);
                        } catch (error) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Request failed:\n$error"),
                              duration: const Duration(seconds: 10),
                            ),
                          );
                        }
                      } catch (error) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error:\n$error"),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                      }
                    },

                    child: Container(
                      height: 150,
                      width: 150,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 89, 35, 139),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon((Icons.mic), size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 500,
              right: 0,
              left: 0,
              child: Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
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
          ],
        ),
      ),
    );
  }
}
