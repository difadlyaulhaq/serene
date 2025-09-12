import 'package:flutter/material.dart';
import 'package:serene/ui/widgets/gradient_background';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _State();
}

class _State extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Text(
            'Chat Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      )
    );
  }
}
