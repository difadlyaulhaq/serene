import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chat; // <-- Tambahkan variabel untuk sesi chat

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      // ignore: avoid_print
      print('GEMINI_API_KEY not found in .env file');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "Kamu adalah Serene, seorang teman AI yang empatik dan suportif dari aplikasi Serene. "
          "Tugasmu adalah menjadi pendengar yang baik, memberikan dukungan emosional, "
          "dan membantu pengguna merenungkan perasaan mereka. Jangan pernah memberikan nasihat medis atau diagnosis. "
          "Gunakan bahasa yang hangat, ramah, dan tidak menghakimi. Selalu validasi perasaan pengguna. "
          "Sapa pengguna saat pertama kali memulai percakapan."),
    );

    // Memulai sesi chat saat service diinisialisasi
    _chat = _model?.startChat(); // <-- Inisialisasi sesi chat
  }

  // --- FUNGSI BARU UNTUK STREAMING ---
  Stream<String?> sendMessageStream(String message) {
    if (_chat == null) {
      // Mengembalikan stream error jika chat tidak terinisialisasi
      return Stream.error("Sesi chat belum terinisialisasi.");
    }

    try {
      final content = Content.text(message);
      // Mengirim pesan sebagai stream dan mem-filter hasilnya
      return _chat!.sendMessageStream(content).map((response) {
        return response.text; // Hanya mengambil bagian teks dari respons
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error sending message stream: $e");
      return Stream.error("Gagal mengirim pesan.");
    }
  }
}