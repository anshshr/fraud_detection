import 'package:flutter/material.dart';
import 'package:fraud_detection/pages/multilingual_chat_bot/services/langchain_service.dart';
import 'package:fraud_detection/pages/multilingual_chat_bot/services/speak_words.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

class RecordAudio extends StatefulWidget {
  const RecordAudio({super.key});

  @override
  State<RecordAudio> createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {
  SpeechToText speechToText = SpeechToText();
  String text = "Hold the button to start speaking";
  bool isListening = false;
  bool isProcessing = false;

  void startListening() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        isListening = true;
      });
      speechToText.listen(
        onResult: (result) {
          setState(() {
            text = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() async {
    setState(() {
      isListening = false;
      isProcessing = true;
    });
    speechToText.stop();

    print("Passing the text to AI");
    print(text);
    String ans = await sendMessage(text);
    print("AI response received");
    await speak(ans.replaceAll("*", ""));

    setState(() {
      isProcessing = false;
    });
    print("Done");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPEECH TO TEXT'),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cera Pro',
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isProcessing
          ? null
          : AvatarGlow(
              animate: isListening,
              duration: const Duration(seconds: 2),
              glowColor: const Color.fromARGB(255, 7, 181, 255),
              repeat: true,
              startDelay: const Duration(milliseconds: 100),
              child: GestureDetector(
                onTapDown: (_) => startListening(),
                onTapUp: (_) => stopListening(),
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 40,
                  child: Icon(
                    isListening ? Icons.pause : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
    );
  }
}
