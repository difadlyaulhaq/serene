import 'package:flutter/material.dart';
import 'package:serene/ui/page/chat_page.dart';
import 'package:serene/ui/page/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene',
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/chatscreen': (context) => const ChatPage(),
      },
    );
  }
}

