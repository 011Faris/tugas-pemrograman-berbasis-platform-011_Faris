import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nim = TextEditingController();
  final password = TextEditingController();
  String msg = '';

  Future<void> login() async {
    // Tanpa try-catch, backend yang mati membuat aplikasi crash
    // (Connection refused). Tangkap dan tampilkan sebagai pesan.
    try {
      final res = await http.post(
        // PENTING: emulator Android pakai 10.0.2.2 untuk menunjuk ke laptopmu.
        // Kalau pakai Chrome (flutter run -d chrome), ganti jadi localhost.
        Uri.parse('http://10.0.2.2:3000/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nim': nim.text, 'password': password.text}),
      );
      final body = jsonDecode(res.body);
      setState(() => msg = res.statusCode == 200
          ? 'Halo ${body['data']['user']['nama']}'
          : 'Gagal (${res.statusCode}): ${body['message']}');
    } catch (e) {
      setState(() => msg = 'Tidak dapat terhubung ke server. Periksa alamat backend.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Pertemuan 3')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nim, decoration: const InputDecoration(labelText: 'NIM')),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: login, child: const Text('Masuk')),
            Text(msg),
          ],
        ),
      ),
    );
  }
}