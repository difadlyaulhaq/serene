import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:serene/services/gemini_service.dart';
import 'package:serene/shared/theme.dart';
import 'package:serene/ui/page/camera_page.dart';
import 'package:serene/ui/widgets/gradient_background.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GeminiService _geminiService = GeminiService();

  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'You');
  final ChatUser _geminiUser = ChatUser(
    id: '2',
    firstName: 'Serene',
    profileImage: 'assets/logo.png',
  );

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _sendMessage(
      ChatMessage(text: "Halo", user: _currentUser, createdAt: DateTime.now()),
      isInitialMessage: true,
    );
  }

  // --- FUNGSI _sendMessage SEKARANG MENGGUNAKAN STREAM ---
  void _sendMessage(ChatMessage message, {bool isInitialMessage = false}) {
    // Tampilkan pesan pengguna di UI jika bukan pesan awal
    if (!isInitialMessage) {
      setState(() {
        _messages.insert(0, message);
      });
    }

    // Tampilkan indikator "mengetik..."
    setState(() {
      _isTyping = true;
    });

    // Buat pesan kosong untuk AI yang akan diisi oleh stream
    var aiResponse = ChatMessage(
      user: _geminiUser,
      createdAt: DateTime.now(),
      text: "", // Mulai dengan teks kosong
    );

    // Tambahkan pesan kosong AI ke daftar pesan agar bisa di-update
    setState(() {
      _messages.insert(0, aiResponse);
    });

    // Cek apakah pesan memiliki gambar
    Stream<String?> stream;
    if (message.medias != null && message.medias!.isNotEmpty) {
      // Jika ada gambar, gunakan fungsi untuk gambar
      final imageFile = File(message.medias!.first.url);
      stream = _geminiService.sendMessageWithImageStream(message.text, imageFile);
    } else {
      // Jika tidak ada gambar, gunakan fungsi text biasa
      stream = _geminiService.sendMessageStream(message.text);
    }

    // Dengarkan stream yang masuk
    stream.listen(
      (responseTextChunk) {
        // Update teks pada pesan AI yang sudah ada
        setState(() {
          aiResponse.text += responseTextChunk ?? '';
        });
      },
      onDone: () {
        // Sembunyikan indikator "mengetik..." saat stream selesai
        setState(() {
          _isTyping = false;
        });
      },
      onError: (error) {
        // Handle jika ada error dari stream
        setState(() {
          aiResponse.text = "Maaf, terjadi kesalahan. Coba lagi nanti ya.";
          _isTyping = false;
        });
      },
    );
  }

  // --- FUNGSI UNTUK MENANGANI FOTO ---
  void _sendImageMessage(File imageFile) {
    // Buat pesan dengan gambar
    final imageMessage = ChatMessage(
      user: _currentUser,
      createdAt: DateTime.now(),
      text: "Aku mengirimkan foto ini, tolong lihat dan berikan tanggapanmu",
      medias: [
        ChatMedia(
          url: imageFile.path,
          fileName: "image.jpg",
          type: MediaType.image,
        ),
      ],
    );

    // Kirim pesan gambar
    _sendMessage(imageMessage);
  }

  // --- FUNGSI UNTUK MEMBUKA KAMERA ---
  Future<void> _openCamera() async {
    try {
      final File? imageFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );

      if (imageFile != null) {
        _sendImageMessage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka kamera: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Serene'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: subHeadingStyle.copyWith(color: darkGray),
        actions: [
          // Tambahkan tombol kamera di AppBar
          IconButton(
            icon: Icon(Icons.camera_alt, color: darkGray),
            onPressed: _openCamera,
            tooltip: 'Ambil Foto',
          ),
        ],
      ),
      body: GradientBackground(
        child: DashChat(
          currentUser: _currentUser,
          onSend: _sendMessage,
          messages: _messages,
          typingUsers: _isTyping ? [_geminiUser] : [],
          messageOptions: MessageOptions(
            currentUserContainerColor: blue,
            containerColor: white,
            textColor: darkGray,
            showTime: true,
            messagePadding: const EdgeInsets.all(12),
            borderRadius: 18.0,
          ),
          inputOptions: InputOptions(
            inputTextStyle: TextStyle(color: darkGray),
            cursorStyle: CursorStyle(color: darkGray),
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: white,
              hintText: "Ketikkan sesuatu...",
              hintStyle: TextStyle(color: softGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            // Tambahkan trailing widget untuk tombol kamera
            trailing: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: blue),
                onPressed: _openCamera,
                tooltip: 'Ambil Foto',
              ),
            ],
          ),
        ),
      ),
    );
  }
}