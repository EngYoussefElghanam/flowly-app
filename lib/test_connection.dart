import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String status = "Press button to test";
  // ⚠️ USE YOUR IP HERE. 'localhost' WILL FAIL.
  final String backendUrl = 'http://192.168.1.68:3000';

  Future<void> testConnection() async {
    setState(() => status = "Connecting...");
    try {
      final dio = Dio();
      // We try to hit a route that doesn't require Auth, or just check if server responds.
      // Since we don't have a public 'GET /', let's try a POST to login with fake data.
      // If we get 401 or 404, it means we REACHED the server. That's a success.
      // If we get "Connection Refused", that's a failure.

      final response = await dio.post(
        '$backendUrl/login',
        data: {"email": "test@test.com", "password": "wrongpassword"},
      );

      // We expect this to fail (401), but if we get a response, the connection is ALIVE.
      setState(
        () => status = "✅ Success! Server responded: ${response.statusCode}",
      );
    } on DioException catch (e) {
      if (e.response != null) {
        // Server replied with an error (e.g., 401 Wrong Password) -> THIS IS GOOD!
        setState(
          () => status =
              "✅ Connected! Server said: ${e.response?.statusCode} (${e.response?.statusMessage})",
        );
      } else {
        // Server did not reply -> THIS IS BAD.
        setState(() => status = "❌ Error: ${e.message}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backend Handshake")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: testConnection,
              child: const Text("Ping Backend"),
            ),
          ],
        ),
      ),
    );
  }
}
